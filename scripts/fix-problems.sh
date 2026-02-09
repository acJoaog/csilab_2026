#!/bin/bash

echo "=== Corrigindo problemas da infraestrutura IoT ==="

# 1. Parar todos os containers
echo "Parando containers..."
sudo docker-compose down

# 2. Matar mosquitto local se estiver rodando
echo "Verificando mosquitto local..."
sudo systemctl stop mosquitto 2>/dev/null || true
sudo pkill mosquitto 2>/dev/null || true

# 3. Atualizar requirements.txt da Flask API
echo "Atualizando requirements.txt..."
cat > flask-api/requirements.txt << 'EOF'
Flask==2.3.3
Flask-CORS==4.0.0
Flask-JWT-Extended==4.5.3
Flask-SQLAlchemy==3.1.1
psycopg2-binary==2.9.7
SQLAlchemy==2.0.19
paho-mqtt==1.6.1
python-dotenv==1.0.0
gunicorn==21.2.0
cryptography==41.0.4
werkzeug==3.0.1
EOF

# 4. Corrigir configuração do PostgreSQL
echo "Configurando PostgreSQL..."
cat > postgres/postgresql.conf << 'EOF'
listen_addresses = '*'
port = 5432
max_connections = 100
ssl = on
ssl_cert_file = '/var/lib/postgresql/certs/server.crt'
ssl_key_file = '/var/lib/postgresql/certs/server.key'
ssl_ca_file = '/var/lib/postgresql/certs/ca.crt'
ssl_min_protocol_version = 'TLSv1.2'
password_encryption = scram-sha-256
log_destination = 'stderr'
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
shared_buffers = 128MB
EOF

# 5. Corrigir docker-compose.yml para usar porta diferente do WebSocket
echo "Atualizando docker-compose.yml..."
sed -i 's/9001:9001/9002:9001/g' docker-compose.yml

# 6. Reconstruir imagens
echo "Reconstruindo imagens..."
sudo docker-compose build

# 7. Remover volumes antigos se existirem
echo "Limpando volumes antigos..."
sudo docker volume rm smartlab_postgres-data 2>/dev/null || true

# 8. Iniciar serviços
echo "Iniciando serviços..."
sudo docker-compose up -d

echo "Aguardando inicialização..."
sleep 15

# 9. Verificar status
echo -e "\n=== Status dos Containers ==="
sudo docker ps

echo -e "\n=== Logs PostgreSQL ==="
sudo docker logs smartlab-postgres --tail 20

echo -e "\n=== Logs Flask API ==="
sudo docker logs smartlab-flask-api --tail 20

echo -e "\n=== Logs MQTT ==="
sudo docker logs smartlab-mqtt-broker --tail 10

echo -e "\n=== Testes ==="
echo "Testando MQTT..."
timeout 5 mosquitto_sub -h localhost -p 8883 -t 'test' \
  --cafile certs/ca.crt \
  --cert certs/client.crt \
  --key certs/client.key \
  -C 1 -v && echo "✓ MQTT OK" || echo "✗ MQTT falhou"

echo "Testando API..."
curl -s -k https://localhost:8443/health 2>/dev/null && echo "✓ API OK" || echo "✗ API falhou"

echo -e "\n=== Instruções ==="
echo "MQTT TLS: mqtts://localhost:8883"
echo "WebSocket: wss://localhost:9002"
echo "API HTTPS: https://localhost:8443"
echo "PostgreSQL: localhost:5432 (usuário: iot_user, senha: iot_password_secure)"