from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import os

def generate_bill_pdf(bill, customer_name):
    filename = f"bill_{bill['customer_id']}.pdf"
    filepath = os.path.join("../static", filename)

    c = canvas.Canvas(filepath, pagesize=letter)

    c.setFont("Helvetica-Bold", 16)
    c.drawString(200, 750, "Electricity Bill")

    c.setFont("Helvetica", 12)

    c.drawString(50, 700, f"Customer Name: {customer_name}")
    c.drawString(50, 680, f"Customer ID: {bill['customer_id']}")

    c.drawString(50, 640, f"Billing Period: {bill['billing_period_start']} to {bill['billing_period_end']}")
    c.drawString(50, 620, f"Units Consumed: {bill['units_consumed']}")
    c.drawString(50, 600, f"Amount Due: ₹{bill['amount_due']}")

    c.drawString(50, 560, f"Generated Date: {bill['generated_date']}")
    c.drawString(50, 540, f"Due Date: {bill['due_date']}")

    c.drawString(50, 500, f"Status: {bill['status']}")

    c.save()

    return filename