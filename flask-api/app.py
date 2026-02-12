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
            # SSL ativo?
            cur.execute("SHOW ssl;")
            ssl_on = cur.fetchone()[0]
            
            # Detalhes da conexão atual
            cur.execute("""
                SELECT 
                    ssl_cipher,
                    ssl_version,
                    ssl_compression
                FROM pg_stat_ssl 
                WHERE pid = pg_backend_pid();
            """)
            result = cur.fetchone()
            
            # Configurações SSL do servidor
            cur.execute("""
                SELECT name, setting 
                FROM pg_settings 
                WHERE name IN ('ssl_ciphers', 'ssl_min_protocol_version');
            """)
            ssl_settings = dict(cur.fetchall())

    return {
        "ssl": ssl_on,
        "cipher": result[0] if result else None,
        "ssl_version": result[1] if result and len(result) > 1 else None,
        "compression": result[2] if result and len(result) > 2 else None,
        "server_ciphers": ssl_settings.get('ssl_ciphers'),
        "min_protocol": ssl_settings.get('ssl_min_protocol_version')
    }

