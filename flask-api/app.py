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
        sslcert=os.getenv("DB_SSLCERT"),
        sslkey=os.getenv("DB_SSLKEY"),
    )

@app.route("/")
def health():
    return {"status": "ok"}

@app.route("/db-check")
def db_check():
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            # Verifica se SSL está ativo
            cur.execute("SHOW ssl;")
            ssl_on = cur.fetchone()[0]
            
            # USA A FUNÇÃO CORRETA - NÃO É COLUNA!
            cipher = None
            try:
                cur.execute("SELECT ssl_cipher();")
                result = cur.fetchone()
                if result:
                    cipher = result[0]
            except psycopg.Error:
                cipher = "não disponível"
            
            # Versão SSL (opcional)
            ssl_version = None
            try:
                cur.execute("SELECT ssl_version();")
                result = cur.fetchone()
                if result:
                    ssl_version = result[0]
            except psycopg.Error:
                ssl_version = "não disponível"

    return {
        "ssl": ssl_on,
        "cipher": cipher,
        "ssl_version": ssl_version
    }

