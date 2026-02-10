#!/bin/bash
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

    -- Criar usuário admin padrão (senha: admin123 - alterar em produção)
    INSERT INTO users (username, email, password_hash) 
    VALUES ('admin', 'admin@iot.com', '$2b$12$YourHashedPasswordHere')
    ON CONFLICT (username) DO NOTHING;
EOSQL