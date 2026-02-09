#!/bin/sh

echo "Configurando SSL para PostgreSQL..."

# Copiar certificados do volume montado
if [ -f "/var/lib/postgresql/certs/server.crt" ]; then
    cp /var/lib/postgresql/certs/server.crt /var/lib/postgresql/server.crt
    cp /var/lib/postgresql/certs/server.key /var/lib/postgresql/server.key
    cp /var/lib/postgresql/certs/ca.crt /var/lib/postgresql/root.crt
    
    # Configurar permissões
    chown postgres:postgres /var/lib/postgresql/server.* /var/lib/postgresql/root.crt
    chmod 600 /var/lib/postgresql/server.key
    
    echo "Certificados SSL configurados com sucesso"
else
    echo "Aviso: Certificados SSL não encontrados"
fi