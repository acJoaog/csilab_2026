FROM postgres:15-alpine

# Instalações necessárias
RUN apk add --no-cache openssl

# CRIA O DIRETÓRIO E COPIA OS CERTIFICADOS DURANTE O BUILD
# IMPORTANTE: Os certificados devem estar no contexto do build
COPY certs /etc/postgresql/certs/

# JÁ MUDA O DONO AQUI, como root
RUN chown -R postgres:postgres /etc/postgresql/certs && \
    chmod 600 /etc/postgresql/certs/server.key

# Define permissões CORRETAS e ANTES de qualquer execução
RUN mkdir -p /etc/postgresql && \
    chown -R postgres:postgres /etc/postgresql && \
    chmod 700 /etc/postgresql/certs && \
    chmod 600 /etc/postgresql/certs/server.key && \
    chmod 644 /etc/postgresql/certs/server.crt && \
    chmod 644 /etc/postgresql/certs/ca.crt

# Scripts de inicialização
COPY init-db.sh /docker-entrypoint-initdb.d/
COPY setup-ssl.sh /docker-entrypoint-initdb.d/01-setup-ssl.sh
RUN chmod +x /docker-entrypoint-initdb.d/*.sh

EXPOSE 5432