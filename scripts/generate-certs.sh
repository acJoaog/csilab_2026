#!/bin/bash
set -e

# =========================================================
# CONFIG
# =========================================================
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CERTS_DIR="$BASE_DIR/certs"
EXPORT_DIR="$BASE_DIR/export"
DAYS_CA=3650
DAYS_CERT=365

SUBJ_CA="/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=IoT CA"

SUBJ_MQTT="/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=mqtt-broker"
SUBJ_POSTGRES="/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=postgres-db"
SUBJ_FLASK="/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=flask-api"
SUBJ_CLIENT="/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=iot-client"

# =========================================================
# HELPERS
# =========================================================
create_dir() {
  mkdir -p "$1"
}

gen_key() {
  openssl genrsa -out "$1" 2048
}

gen_csr() {
  openssl req -new -key "$1" -out "$2" -subj "$3"
}

sign_cert() {
  openssl x509 -req \
    -in "$1" \
    -CA "$CERTS_DIR/ca/ca.crt" \
    -CAkey "$CERTS_DIR/ca/ca.key" \
    -CAcreateserial \
    -out "$2" \
    -days "$DAYS_CERT" \
    -sha256
}

# =========================================================
# SETUP DIRS
# =========================================================
echo "📁 Criando diretórios..."
create_dir "$CERTS_DIR/ca"
create_dir "$CERTS_DIR/mqtt"
create_dir "$CERTS_DIR/postgres"
create_dir "$CERTS_DIR/flask"
create_dir "$CERTS_DIR/client"

create_dir "$EXPORT_DIR"

# =========================================================
# CA
# =========================================================
echo "🔐 Gerando CA..."
gen_key "$CERTS_DIR/ca/ca.key"
openssl req -new -x509 \
  -key "$CERTS_DIR/ca/ca.key" \
  -out "$CERTS_DIR/ca/ca.crt" \
  -days "$DAYS_CA" \
  -subj "$SUBJ_CA"

chmod 600 "$CERTS_DIR/ca/ca.key"
chmod 644 "$CERTS_DIR/ca/ca.crt"

# =========================================================
# MQTT
# =========================================================
echo "🔐 Gerando certificado MQTT..."
gen_key "$CERTS_DIR/mqtt/server.key"
gen_csr "$CERTS_DIR/mqtt/server.key" "$CERTS_DIR/mqtt/server.csr" "$SUBJ_MQTT"
sign_cert "$CERTS_DIR/mqtt/server.csr" "$CERTS_DIR/mqtt/server.crt"
rm "$CERTS_DIR/mqtt/server.csr"
chmod 600 "$CERTS_DIR/mqtt/server.key"
chmod 644 "$CERTS_DIR/mqtt/server.crt"

# =========================================================
# POSTGRES
# =========================================================
echo "🔐 Gerando certificado PostgreSQL..."
gen_key "$CERTS_DIR/postgres/server.key"
gen_csr "$CERTS_DIR/postgres/server.key" "$CERTS_DIR/postgres/server.csr" "$SUBJ_POSTGRES"
sign_cert "$CERTS_DIR/postgres/server.csr" "$CERTS_DIR/postgres/server.crt"
rm "$CERTS_DIR/postgres/server.csr"
chmod 600 "$CERTS_DIR/postgres/server.key"
chmod 644 "$CERTS_DIR/postgres/server.crt"

# =========================================================
# FLASK
# =========================================================
echo "🔐 Gerando certificado Flask..."
gen_key "$CERTS_DIR/flask/server.key"
gen_csr "$CERTS_DIR/flask/server.key" "$CERTS_DIR/flask/server.csr" "$SUBJ_FLASK"
sign_cert "$CERTS_DIR/flask/server.csr" "$CERTS_DIR/flask/server.crt"
rm "$CERTS_DIR/flask/server.csr"
chmod 600 "$CERTS_DIR/flask/server.key"
chmod 644 "$CERTS_DIR/flask/server.crt"

# =========================================================
# CLIENT
# =========================================================
echo "🔐 Gerando certificado CLIENT..."
gen_key "$CERTS_DIR/client/client.key"
gen_csr "$CERTS_DIR/client/client.key" "$CERTS_DIR/client/client.csr" "$SUBJ_CLIENT"
sign_cert "$CERTS_DIR/client/client.csr" "$CERTS_DIR/client/client.crt"
rm "$CERTS_DIR/client/client.csr"
chmod 600 "$CERTS_DIR/client/client.key"
chmod 644 "$CERTS_DIR/client/client.crt"

# =========================================================
# EXPORT
# =========================================================
echo "📦 Exportando certificados públicos..."
cp "../certs/ca/ca.crt" "$EXPORT_DIR/"
cp "$CERTS_DIR/client/client.crt" "$EXPORT_DIR/"
cp "$CERTS_DIR/client/client.key" "$EXPORT_DIR/"

chmod 777 "$EXPORT_DIR"
chmod 777 "$EXPORT_DIR"/*

echo "✅ Certificados gerados com sucesso"
