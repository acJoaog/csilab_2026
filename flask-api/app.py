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
            
            # Tenta obter a cipher SSL, retorna None se não disponível
            try:
                cur.execute("""
                    SELECT ssl_cipher 
                    FROM pg_stat_ssl 
                    WHERE pid = pg_backend_pid();
                """)
                result = cur.fetchone()
                cipher = result[0] if result else None
            except psycopg.Error:
                cipher = None

    return {
        "ssl": ssl_on,
        "cipher": cipher
    }

