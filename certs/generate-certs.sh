#!/bin/bash

# Diretórios
mkdir -p mqtt postgres flask

echo "=== Gerando Autoridade Certificadora (CA) ==="
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=IoT CA"

echo "=== Gerando certificados para MQTT Broker ==="
# Chave privada do broker
openssl genrsa -out mqtt/server.key 2048

# CSR do broker
openssl req -new -key mqtt/server.key -out mqtt/server.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=mqtt-broker"

# Certificado assinado pela CA
openssl x509 -req -in mqtt/server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out mqtt/server.crt -days 365 -sha256

# Remover CSR
rm mqtt/server.csr

echo "=== Gerando certificados para PostgreSQL ==="
openssl genrsa -out postgres/server.key 2048
openssl req -new -key postgres/server.key -out postgres/server.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=postgres-db"

openssl x509 -req -in postgres/server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out postgres/server.crt -days 365 -sha256

rm postgres/server.csr
chmod 600 postgres/server.key

echo "=== Gerando certificados para Flask API ==="
openssl genrsa -out flask/server.key 2048
openssl req -new -key flask/server.key -out flask/server.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=flask-api"

openssl x509 -req -in flask/server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out flask/server.crt -days 365 -sha256

rm flask/server.csr

echo "=== Gerando certificados para clientes (IoT devices) ==="
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr \
  -subj "/C=BR/ST=Sao_Paulo/L=Sao_Paulo/O=IoT Company/CN=iot-device"

openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out client.crt -days 365 -sha256

rm client.csr

echo "=== Gerando arquivo PEM combinado para clientes ==="
cat client.crt client.key > client.pem

echo "=== Copiando CA para todos os serviços ==="
mkdir -p mqtt/certs
cp ca.crt ../mqtt/certs/ca.crt
cp server.crt ../mqtt/certs/server.crt
cp server.key ../mqtt/certs/server.key

cp ca.crt postgres/ca.crt
cp ca.crt flask/ca.crt

echo "=== Certificados gerados com sucesso! ==="
echo ""
echo "Arquivos disponíveis:"
echo "- ca.crt: Certificado da autoridade certificadora"
echo "- client.crt / client.key: Para dispositivos IoT"
echo "- client.pem: Certificado e chave combinados"
echo "- mqtt/: Certificados do broker MQTT"
echo "- postgres/: Certificados do PostgreSQL"
echo "- flask/: Certificados da API Flask"