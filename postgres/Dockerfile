FROM postgres:15-alpine

# Instalações necessárias
RUN apk add --no-cache openssl

# Cria diretório para certificados
RUN mkdir -p /var/lib/postgresql/certs

# Copiar certificados com permissões adequadas
COPY ./certs/ /var/lib/postgresql/certs/

# Ajusta permissões ANTES de copiar para data directory
RUN chown -R postgres:postgres /var/lib/postgresql/certs && \
    chmod 600 /var/lib/postgresql/certs/server.key && \
    chmod 644 /var/lib/postgresql/certs/server.crt /var/lib/postgresql/certs/ca.crt

# Copia configurações
COPY ./conf/postgresql.conf /var/lib/postgresql/data/postgresql.conf
COPY ./conf/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf

# Script de inicialização
COPY init-db.sh /docker-entrypoint-initdb.d/

# Script para configurar SSL
COPY setup-ssl.sh /docker-entrypoint-initdb.d/01-setup-ssl.sh

EXPOSE 5432