#!/bin/bash

chown -R postgres:postgres /etc/postgresql/certs
chmod 600 /etc/postgresql/certs/server.key
chmod 644 /etc/postgresql/certs/server.crt /etc/postgresql/certs/ca.crt

set -e

echo "=== Inicializando banco de dados SmartLab ==="

# Cria usuário de aplicação (se não existir)
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    
    CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    echo "=== Banco de dados inicializado com sucesso! ==="

    CREATE USER smartlab WITH PASSWORD 'admin';
    GRANT CONNECT ON DATABASE smartlab_db TO smartlab;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO smartlab;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO smartlab;

    -- Criar usuário admin padrão (senha: admin123 - alterar em produção)
    INSERT INTO users (username, email, password_hash) 
    VALUES ('admin', 'admin@iot.com', 'admin')
    ON CONFLICT (username) DO NOTHING;
EOSQL