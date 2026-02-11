FROM postgres:15-alpine

RUN apk add --no-cache openssl

# Copia e ajusta permissões em UM ÚNICO LAYER
COPY certs /etc/postgresql/certs/
RUN chown -R postgres:postgres /etc/postgresql/certs && \
    chmod 700 /etc/postgresql/certs && \
    chmod 600 /etc/postgresql/certs/server.key && \
    chmod 644 /etc/postgresql/certs/server.crt && \
    chmod 644 /etc/postgresql/certs/ca.crt

COPY init-db.sh /docker-entrypoint-initdb.d/
COPY setup-ssl.sh /docker-entrypoint-initdb.d/01-setup-ssl.sh
RUN chmod +x /docker-entrypoint-initdb.d/*.sh

EXPOSE 5432