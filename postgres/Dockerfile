FROM postgres:15-alpine

# Instalações necessárias
RUN apk add --no-cache openssl

# Cria diretório para certificados
RUN mkdir -p /etc/postgresql/certs/

# Copiar certificados com permissões adequadas
COPY ./certs/ /etc/postgresql/certs/

# Ajusta permissões ANTES de copiar para data directory
RUN chown -R postgres:postgres /etc/postgresql/certs/ && \
    chmod 600 /etc/postgresql/certs/server.key && \
    chmod 644 /etc/postgresql/certs/server.crt /etc/postgresql/certs/ca.crt

# Copia configurações
COPY ./conf/postgresql.conf /tmp/postgresql.conf
COPY ./conf/pg_hba.conf /tmp/pg_hba.conf

# Script de inicialização
COPY init-db.sh /docker-entrypoint-initdb.d/

# Script para configurar SSL
COPY setup-ssl.sh /docker-entrypoint-initdb.d/01-setup-ssl.sh

EXPOSE 5432