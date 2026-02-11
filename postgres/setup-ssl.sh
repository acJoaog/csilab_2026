#!/bin/bash
set -e

echo "=== Configurando SSL para PostgreSQL ==="

# Garante permissões corretas para os certificados
chown -R postgres:postgres /var/lib/postgresql/certs
chmod 600 /var/lib/postgresql/certs/server.key
chmod 644 /var/lib/postgresql/certs/server.crt /var/lib/postgresql/certs/ca.crt

# Copia configurações para o data directory
if [ -f /tmp/postgresql.conf ]; then
    cp /tmp/postgresql.conf /var/lib/postgresql/data/postgresql.conf
    chown postgres:postgres /var/lib/postgresql/data/postgresql.conf
fi

if [ -f /tmp/pg_hba.conf ]; then
    cp /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
    chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf
fi

echo "=== Configuração SSL concluída ==="