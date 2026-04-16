"""FINAL FULL Flask Backend - Electricity Bill System"""

from flask import Flask, render_template, request, redirect, url_for, session, jsonify, flash, Response
from db import Database
from bill_logic import BillLogic
from pdf_generator import generate_bill_pdf
import csv
from io import StringIO

app = Flask(__name__, template_folder='../templates', static_folder='../static')
app.secret_key = "secret123"


def get_db():
    return Database()


# ---------------- AUTH ----------------
def is_logged_in():
    return 'user' in session


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        db = get_db()
        user = db.query(
            "SELECT * FROM users WHERE username=%s AND password=%s",
            (request.form['username'], request.form['password'])
        )
        db.close()

        if user:
            session['user'] = request.form['username']
            return redirect('/')
        else:
            flash("Invalid credentials")

    return render_template('login.html')


@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')


# ---------------- HOME ----------------
@app.route('/')
def index():
    if not is_logged_in():
        return redirect('/login')

    db = get_db()

    search = request.args.get('search', '')

    customers = db.query(
        "SELECT * FROM customers WHERE name LIKE %s",
        ('%' + search + '%',)
    )

    total_customers = db.query(
        "SELECT COUNT(*) as count FROM customers")[0]['count']

    total_revenue = db.query(
        "SELECT SUM(amount_due) as total FROM bills")[0]['total'] or 0

    unpaid = db.query(
        "SELECT COUNT(*) as count FROM bills WHERE status='unpaid'")[0]['count']

    db.close()

    return render_template(
        'index.html',
        customers=customers,
        total_customers=total_customers,
        total_revenue=total_revenue,
        unpaid=unpaid
    )


# ---------------- ADD CUSTOMER ----------------
@app.route('/add_customer', methods=['GET', 'POST'])
def add_customer():
    if not is_logged_in():
        return redirect('/login')

    if request.method == 'POST':
        name = request.form['name']
        phone = request.form['phone']

        if not name:
            flash("Name required")
            return redirect('/add_customer')

        if phone and not phone.isdigit():
            flash("Phone must be numeric")
            return redirect('/add_customer')

        db = get_db()

        db.execute(
            """INSERT INTO customers 
            (name,address,phone,email,meter_number,connection_date)
            VALUES (%s,%s,%s,%s,%s,%s)""",
            (
                name,
                request.form['address'],
                phone,
                request.form['email'],
                request.form['meter_number'],
                request.form['connection_date']
            )
        )

        db.close()
        flash("Customer added")
        return redirect('/')

    return render_template('add_customer.html')


# ---------------- ADD READING ----------------
@app.route('/add_reading', methods=['GET', 'POST'])
def add_reading():
    if not is_logged_in():
        return redirect('/login')

    db = get_db()
    customers = db.query("SELECT customer_id, name FROM customers")

    if request.method == 'POST':
        db.execute(
            """INSERT INTO meter_readings 
            (customer_id, reading_date, units_consumed)
            VALUES (%s, %s, %s)""",
            (
                request.form['customer_id'],
                request.form['reading_date'],
                request.form['units_consumed']
            )
        )
        db.close()
        flash("Reading added")
        return redirect('/')

    db.close()
    return render_template('add_reading.html', customers=customers)


# ---------------- GENERATE BILL ----------------
@app.route('/generate_bill', methods=['GET', 'POST'])
def generate_bill():
    if not is_logged_in():
        return redirect('/login')

    db = get_db()
    customers = db.query("SELECT customer_id, name FROM customers")

    if request.method == 'POST':
        customer_id = request.form['customer_id']

        readings = db.query(
            """SELECT units_consumed 
               FROM meter_readings 
               WHERE customer_id=%s 
               ORDER BY reading_date DESC LIMIT 2""",
            (customer_id,)
        )

        if len(readings) < 2:
            flash("Need at least 2 readings")
            return redirect('/generate_bill')

        units = readings[0]['units_consumed'] - readings[1]['units_consumed']

        bill = BillLogic.build_bill(
            customer_id,
            request.form['start_date'],
            request.form['end_date'],
            units
        )

        db.execute(
            """INSERT INTO bills 
            (customer_id,billing_period_start,billing_period_end,units_consumed,amount_due,generated_date,due_date,status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
            (
                bill['customer_id'],
                bill['billing_period_start'],
                bill['billing_period_end'],
                bill['units_consumed'],
                bill['amount_due'],
                bill['generated_date'],
                bill['due_date'],
                bill['status']
            )
        )

        customer = db.query(
            "SELECT name FROM customers WHERE customer_id=%s",
            (customer_id,)
        )[0]

        pdf = generate_bill_pdf(bill, customer['name'])

        db.close()

        return f'<a href="/static/{pdf}" target="_blank">Download PDF</a>'

    db.close()
    return render_template('generate_bill.html', customers=customers)


# ---------------- PAYMENT ----------------
@app.route('/payment', methods=['GET', 'POST'])
def payment():
    if not is_logged_in():
        return redirect('/login')

    db = get_db()

    bills = db.query("""
        SELECT b.bill_id,c.name,b.amount_due 
        FROM bills b 
        JOIN customers c ON b.customer_id=c.customer_id 
        WHERE status='unpaid'
    """)

    if request.method == 'POST':
        db.execute(
            "INSERT INTO payments (bill_id,payment_date,amount_paid,payment_method) VALUES (%s,%s,%s,%s)",
            (
                request.form['bill_id'],
                request.form['payment_date'],
                request.form['amount_paid'],
                request.form['method']
            )
        )

        db.execute(
            "UPDATE bills SET status='paid' WHERE bill_id=%s",
            (request.form['bill_id'],)
        )

        db.close()
        flash("Payment successful")
        return redirect('/')

    db.close()
    return render_template('payment.html', bills=bills)


# ---------------- EXPORT CSV ----------------
@app.route('/export')
def export():
    if not is_logged_in():
        return redirect('/login')

    db = get_db()
    data = db.query("SELECT * FROM bills")
    db.close()

    output = StringIO()
    writer = csv.writer(output)

    writer.writerow(["ID", "Customer", "Amount", "Status"])
    for row in data:
        writer.writerow([
            row['bill_id'],
            row['customer_id'],
            row['amount_due'],
            row['status']
        ])

    return Response(
        output.getvalue(),
        mimetype="text/csv",
        headers={"Content-Disposition": "attachment;filename=bills.csv"}
    )


# ---------------- DASHBOARD API ----------------
@app.route('/api/dashboard')
def dashboard():
    db = get_db()

    revenue = db.query(
        "SELECT DATE(generated_date) as date, SUM(amount_due) as total FROM bills GROUP BY date"
    )

    status = db.query(
        "SELECT status, COUNT(*) as count FROM bills GROUP BY status"
    )

    db.close()
    return jsonify({"revenue": revenue, "status": status})


# ---------------- RUN ----------------
if __name__ == '__main__':
    app.run(debug=True)