#!/bin/bash

echo "=== Testando conexão com PostgreSQL TLS ==="

chmod 600 ../../certs/client.key

# Teste com SSL obrigatório
echo "1. Testando conexão com SSL (deve funcionar):"
PGPASSWORD=admin psql "host=localhost port=5432 dbname=smartlab_db user=admin sslmode=require sslcert=../../export/client.crt sslkey=../../export/client.key" -c "SELECT 'Conexão SSL bem-sucedida!' as status;"

echo ""
echo "2. Testando conexão sem SSL (deve falhar):"
PGPASSWORD=admin psql "host=localhost port=5432 dbname=smartlab_db user=admin sslmode=disable" -c "SELECT 'Esta conexão não deve funcionar' as status;" 2>/dev/null || echo "Conexão sem SSL rejeitada (como esperado)"

echo ""
echo "3. Verificando status do SSL no PostgreSQL:"
PGPASSWORD=admin psql "host=localhost port=5432 dbname=smartlab_db user=admin sslmode=require sslcert=../../export/client.crt sslkey=../../export/client.key" -c "SHOW ssl; SELECT version();"

chmod 777 ../../export/client.key