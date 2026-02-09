#!/bin/bash

# Parar mosquitto local se estiver rodando
echo "Verificando mosquitto local..."
sudo systemctl stop mosquitto 2>/dev/null || true
sudo pkill mosquitto 2>/dev/null || true

# Verificar se porta 9001 está em uso
if lsof -Pi :9001 -sTCP:LISTEN -t >/dev/null ; then
    echo "Porta 9001 em uso. Liberando..."
    sudo fuser -k 9001/tcp 2>/dev/null || true
    sleep 2
fi

echo "=== Inicializando Infraestrutura IoT ==="

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker não encontrado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose não encontrado. Por favor, instale o Docker Compose."
    exit 1
fi

# Gerar certificados
echo "Gerando certificados..."
cd certs
chmod +x generate-certs.sh
./generate-certs.sh
cd ..

# Construir e iniciar containers
echo "Construindo e iniciando containers..."
docker-compose down  # Limpar instâncias anteriores
docker-compose build
docker-compose up -d

echo "Aguardando serviços iniciarem..."
sleep 15

# Verificar status dos serviços
echo "=== Status dos Serviços ==="
echo "MQTT Broker:"
docker-compose logs mqtt-broker --tail=10

echo -e "\nPostgreSQL:"
docker-compose logs postgres-db --tail=10

echo -e "\nFlask API:"
docker-compose logs flask-api --tail=10

echo -e "\n=== Informações de Conexão ==="
echo "MQTT Broker (TLS):"
echo "  Endpoint: mqtts://localhost:8883"
echo "  Certificados cliente em: certs/client.crt e certs/client.key"
echo "  CA: certs/ca.crt"
echo ""
echo "Flask API (HTTPS):"
echo "  Endpoint: https://localhost:8443"
echo "  Swagger UI: https://localhost:8443/ (quando implementado)"
echo ""
echo "PostgreSQL (TLS):"
echo "  Host: localhost:5432"
echo "  Database: iot_database"
echo "  User: iot_user"
echo ""
echo "Para testar conexão MQTT:"
echo "  mosquitto_sub -h localhost -p 8883 -t 'test' --cafile certs/ca.crt --cert certs/client.crt --key certs/client.key"
echo ""
echo "Para parar os serviços: docker-compose down"
echo "Para ver logs: docker-compose logs -f"