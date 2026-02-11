#!/bin/sh
set -e

# ===== EXECUTA COMO ROOT PARA CORRIGIR PERMISSÕES =====
echo "🔧 Corrigindo permissões dos certificados..."

# Força permissões corretas
chown postgres:postgres /etc/postgresql/certs/server.key
chmod 600 /etc/postgresql/certs/server.key
chown postgres:postgres /etc/postgresql/certs/server.crt
chmod 644 /etc/postgresql/certs/server.crt
chown postgres:postgres /etc/postgresql/certs/ca.crt
chmod 644 /etc/postgresql/certs/ca.crt

echo "✅ Permissões corrigidas:"
ls -la /etc/postgresql/certs/

# ===== EXECUTA O POSTGRES =====
exec docker-entrypoint.sh "$@"