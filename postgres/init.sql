-- Criar tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de dispositivos IoT
CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id),
    device_name VARCHAR(100),
    device_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'offline',
    last_seen TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar tabela de mensagens MQTT
CREATE TABLE IF NOT EXISTS device_messages (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    message TEXT,
    qos INTEGER DEFAULT 0,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices
CREATE INDEX idx_devices_user_id ON devices(user_id);
CREATE INDEX idx_messages_device_id ON device_messages(device_id);
CREATE INDEX idx_messages_timestamp ON device_messages(timestamp);

-- Criar usuário admin padrão (senha: admin123 - alterar em produção)
INSERT INTO users (username, email, password_hash) 
VALUES ('admin', 'admin@iot.com', '$2b$12$YourHashedPasswordHere')
ON CONFLICT (username) DO NOTHING;