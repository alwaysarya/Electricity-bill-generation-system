# Electricity Bill Management System

A simple DBMS-style project for managing electricity customers, meter readings, bills, and payments.

## Project Structure

- `database/` - SQL schema, sample data, and queries
- `backend/` - Flask backend app, database helper, billing logic
- `templates/` - HTML pages for customer management and billing
- `static/` - styling assets
- `docs/` - ER diagram and design notes
- `screenshots/` - UI and report screenshots

## Setup

1. Create a Python virtual environment.
2. Install dependencies: `pip install flask sqlite3`
3. Initialize the database using `database/schema.sql`.
4. Run the app from `backend/app.py`.

## Notes

The system supports customer management, meter reading entry, bill generation, payment recording, and basic reports.
