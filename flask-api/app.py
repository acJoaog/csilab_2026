from flask import Flask
import os
import psycopg

app = Flask(__name__)

def get_db_connection():
    return psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        sslmode=os.getenv("DB_SSLMODE"),
        sslrootcert=os.getenv("DB_SSLROOTCERT"),
        sslcert=os.getenv("DB_SSLCERT"),
        sslkey=os.getenv("DB_SSLKEY"),
    )

@app.route("/")
def health():
    return {"status": "ok"}
