FROM postgres:15-alpine

# Instalações necessárias
RUN apk add --no-cache openssl

# Cria o diretório de certificados com permissões corretas
RUN mkdir -p /etc/postgresql/certs && \
    chown -R postgres:postgres /etc/postgresql && \
    chmod 700 /etc/postgresql/certs

# Script de inicialização
COPY init-db.sh /docker-entrypoint-initdb.d/
COPY setup-ssl.sh /docker-entrypoint-initdb.d/01-setup-ssl.sh

# Garante que o script seja executável
RUN chmod +x /docker-entrypoint-initdb.d/*.sh

EXPOSE 5432