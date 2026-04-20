from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import mysql.connector
from datetime import date

app = Flask(__name__)
CORS(app)


# ---------------- DB CONNECTION ----------------
def get_db():
    return mysql.connector.connect(
        user="root",
        password="Root@1234",
        database="electricitybill",
        unix_socket="/tmp/mysql.sock"
    )


# ---------------- LOGIN ----------------
@app.route("/login", methods=["POST"])
def login():
    data = request.json

    username = data.get("username")
    password = data.get("password")

    if username == "ARYAN" and password == "0987":
        return jsonify({"success": True})
    else:
        return jsonify({"success": False}), 401


# ---------------- HOME ----------------
@app.route("/")
def home():
    return "Electricity Backend Running ✅"


# ---------------- ADD CUSTOMER ----------------
@app.route("/add_customer", methods=["POST"])
def add_customer():
    data = request.json

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute(
        "INSERT INTO customers (name, meter_number, phone) VALUES (%s, %s, %s)",
        (data["name"], data["meter"], data["phone"])
    )

    conn.commit()
    conn.close()

    return jsonify({"message": "Customer added successfully"})


# ---------------- GET CUSTOMERS ----------------
@app.route("/customers", methods=["GET"])
def get_customers():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM customers")
    customers = cursor.fetchall()

    conn.close()

    return jsonify(customers)


# ---------------- GENERATE BILL ----------------
@app.route("/generate_bill", methods=["POST"])
def generate_bill():
    data = request.json

    customer_id = data.get("customer_id")
    current_reading = int(data.get("current_reading"))

    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT last_reading, tariff_rate FROM customers WHERE id = %s",
        (customer_id,)
    )
    customer = cursor.fetchone()

    if not customer:
        return jsonify({"error": "Customer not found"}), 404

    previous = customer["last_reading"] or 0
    rate = float(customer["tariff_rate"] or 5)

    units = current_reading - previous

    if units < 0:
        return jsonify({"error": "Invalid reading"}), 400

    amount = round(units * rate, 2)

    cursor.execute("""
        INSERT INTO bills 
        (customer_id, previous_reading, current_reading, units_consumed, bill_amount, due_date)
        VALUES (%s, %s, %s, %s, %s, DATE_ADD(CURDATE(), INTERVAL 15 DAY))
    """, (customer_id, previous, current_reading, units, amount))

    cursor.execute(
        "UPDATE customers SET last_reading = %s WHERE id = %s",
        (current_reading, customer_id)
    )

    conn.commit()
    conn.close()

    return jsonify({
        "message": "Bill generated successfully",
        "units": units,
        "amount": amount
    })


# ---------------- PAY BILL ----------------
@app.route("/pay_bill", methods=["POST"])
def pay_bill():
    data = request.json
    bill_id = data.get("bill_id")

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT status FROM bills WHERE id = %s", (bill_id,))
    bill = cursor.fetchone()

    if not bill:
        conn.close()
        return jsonify({"error": "Bill not found"}), 404

    if bill[0] == "Paid":
        conn.close()
        return jsonify({"message": "Bill already paid"})

    cursor.execute("""
        UPDATE bills
        SET status = 'Paid',
            payment_date = CURDATE()
        WHERE id = %s
    """, (bill_id,))

    conn.commit()
    conn.close()

    return jsonify({"message": "Bill paid successfully"})


# ---------------- GET ALL BILLS ----------------
@app.route("/bills", methods=["GET"])
def get_bills():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT b.*, c.name 
        FROM bills b
        JOIN customers c ON b.customer_id = c.id
        ORDER BY b.id DESC
    """)

    bills = cursor.fetchall()

    for bill in bills:
        if bill["status"] == "Unpaid" and bill["due_date"]:
            if date.today() > bill["due_date"]:
                days_late = (date.today() - bill["due_date"]).days
                late_fee = days_late * 2
                bill["late_fee"] = late_fee
                bill["total_amount"] = float(bill["bill_amount"]) + late_fee
            else:
                bill["late_fee"] = 0
                bill["total_amount"] = float(bill["bill_amount"])
        else:
            bill["late_fee"] = 0
            bill["total_amount"] = float(bill["bill_amount"])

    conn.close()
    return jsonify(bills)


# ---------------- DOWNLOAD BILL PDF ----------------
@app.route("/download_bill/<int:bill_id>", methods=["GET"])
def download_bill(bill_id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT b.*, c.name, c.phone
        FROM bills b
        JOIN customers c ON b.customer_id = c.id
        WHERE b.id = %s
    """, (bill_id,))

    bill = cursor.fetchone()
    conn.close()

    if not bill:
        return jsonify({"error": "Bill not found"}), 404

    file_name = f"bill_{bill_id}.pdf"

    c = canvas.Canvas(file_name, pagesize=letter)

    c.setFont("Helvetica-Bold", 20)
    c.drawString(180, 750, "Electricity Bill")

    c.line(50, 740, 550, 740)

    c.setFont("Helvetica", 12)
    c.drawString(50, 700, f"Customer Name: {bill['name']}")
    c.drawString(50, 680, f"Phone: {bill['phone']}")

    c.rect(50, 550, 500, 120)

    c.drawString(60, 640, f"Bill ID: {bill['id']}")
    c.drawString(60, 620, f"Units Consumed: {bill['units_consumed']}")
    c.drawString(60, 600, f"Amount: ₹{bill['bill_amount']}")
    c.drawString(60, 580, f"Status: {bill['status']}")
    c.drawString(60, 560, f"Due Date: {bill['due_date']}")

    c.setFont("Helvetica-Oblique", 10)
    c.drawString(180, 500, "Thank you for using EBMS ⚡")

    c.save()

    return send_file(file_name, as_attachment=True)


# ---------------- RUN ----------------
if __name__ == "__main__":
    app.run(debug=True, port=5050)