echo "Iniciando deploy da infraestrutura IoT..."

docker compose down
docker compose build
docker compose up -d
