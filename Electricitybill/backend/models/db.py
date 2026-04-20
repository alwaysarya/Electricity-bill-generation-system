import mysql.connector

def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",  # change if needed
        database="electricitybill"
    )


def init_db():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS customers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100),
        meter VARCHAR(50),
        phone VARCHAR(20)
    )
    """)

    conn.commit()
    conn.close()