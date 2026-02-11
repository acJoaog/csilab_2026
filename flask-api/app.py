from flask import Flask, jsonify
import psycopg
import ssl
import os

app = Flask(__name__)

def get_db_conn():
    return psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT", 5432),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        sslmode=os.getenv("DB_SSLMODE", "verify-full"),
        sslrootcert=os.getenv("DB_SSLROOTCERT"),
        sslcert=os.getenv("DB_SSLCERT"),
        sslkey=os.getenv("DB_SSLKEY"),
    )

@app.route("/db-check", methods=["GET"])
def db_check():
    try:
        with get_db_conn() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT current_user;")
                user = cur.fetchone()[0]

        return jsonify(status="ok", db_user=user), 200

    except Exception as e:
        return jsonify(status="error", error=str(e)), 500


if __name__ == "__main__":
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    context.load_cert_chain(
        certfile="certs/server.crt",
        keyfile="certs/server.key"
    )

    app.run(
        host="0.0.0.0",
        port=8443,
        ssl_context=context
    )
