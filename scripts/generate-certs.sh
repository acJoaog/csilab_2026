#!/bin/bash

# Diretórios
mkdir -p ../certs/mqtt ../certs/postgres ../certs/flask

echo "=== Gerando Autoridade Certificadora (CA) ==="
openssl genrsa -out ../certs/ca.key 2048
openssl req -new -x509 -days 3650 -key ../certs/ca.key -out ../certs/ca.crt \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=IoT CA"

echo "=== Gerando certificados para MQTT Broker ==="
# Chave privada do broker
openssl genrsa -out ../certs/mqtt/server.key 2048

# CSR do broker
openssl req -new -key ../certs/mqtt/server.key -out ../certs/mqtt/server.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=mqtt-broker"

# Certificado assinado pela CA
openssl x509 -req -in ../certs/mqtt/server.csr -CA ../certs/ca.crt -CAkey ../certs/ca.key \
  -CAcreateserial -out ../certs/mqtt/server.crt -days 365 -sha256

# Remover CSR
rm ../certs/mqtt/server.csr

echo "=== Gerando certificados para PostgreSQL ==="
openssl genrsa -out ../certs/postgres/server.key 2048
openssl req -new -key ../certs/postgres/server.key -out ../certs/postgres/server.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=postgres-db"

openssl x509 -req -in ../certs/postgres/server.csr -CA ../certs/ca.crt -CAkey ../certs/ca.key \
  -CAcreateserial -out ../certs/postgres/server.crt -days 365 -sha256

rm ../certs/postgres/server.csr
chmod 600 ../certs/postgres/server.key

echo "=== Gerando certificados para Flask API ==="
openssl genrsa -out ../certs/flask/server.key 2048
openssl req -new -key ../certs/flask/server.key -out ../certs/flask/server.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=flask-api"

openssl x509 -req -in ../certs/flask/server.csr -CA ../certs/ca.crt -CAkey ../certs/ca.key \
  -CAcreateserial -out ../certs/flask/server.crt -days 365 -sha256

rm ../certs/flask/server.csr

echo "=== Gerando certificados para clientes (IoT devices) ==="
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=iot-device"

openssl x509 -req -in client.csr -CA ../certs/ca.crt -CAkey ../certs/ca.key \
  -CAcreateserial -out client.crt -days 365 -sha256

rm ../certs/client.csr

echo "=== Gerando arquivo PEM combinado para clientes ==="
cat ../certs/client.crt ../certs/client.key > ../certsclient.pem

echo "=== Copiando CA para todos os serviços ==="
mkdir -p ../mqtt/certs
cp ../certs/ca.crt ../mqtt/certs/ca.crt
cp ../certs/mqtt/server.crt ../mqtt/certs/server.crt
cp ../certs/mqtt/server.key ../mqtt/certs/server.key

cp ../certs/ca.crt postgres/ca.crt
cp ../certs/ca.crt flask/ca.crt

echo "=== Certificados gerados com sucesso! ==="
echo ""
echo "Arquivos disponíveis:"
echo "- ca.crt: Certificado da autoridade certificadora"
echo "- client.crt / client.key: Para dispositivos IoT"
echo "- client.pem: Certificado e chave combinados"
echo "- mqtt/: Certificados do broker MQTT"
echo "- postgres/: Certificados do PostgreSQL"
echo "- flask/: Certificados da API Flask"