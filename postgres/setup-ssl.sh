#!/bin/bash
# 01-setup-ssl.sh

echo "=== Configurando SSL do PostgreSQL ==="

# Certifique-se de que os certificados existem e têm permissões corretas
if [ -d "/etc/postgresql/certs" ]; then
    chown -R postgres:postgres /etc/postgresql/certs
    chmod 700 /etc/postgresql/certs
    
    if [ -f "/etc/postgresql/certs/server.key" ]; then
        chmod 600 /etc/postgresql/certs/server.key
        echo "Permissões do server.key ajustadas"
    fi
    
    if [ -f "/etc/postgresql/certs/server.crt" ]; then
        chmod 644 /etc/postgresql/certs/server.crt
    fi
fi

# Copiar arquivos de configuração se existirem
if [ -f "/tmp/postgresql.conf" ]; then
    cp /tmp/postgresql.conf /var/lib/postgresql/data/postgresql.conf
    chown postgres:postgres /var/lib/postgresql/data/postgresql.conf
fi

if [ -f "/tmp/pg_hba.conf" ]; then
    cp /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
    chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf
fi

echo "=== Configuração SSL concluída ==="