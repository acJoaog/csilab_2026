FROM postgres:15-alpine

# Instalações necessárias
RUN apk add --no-cache openssl

# Cria diretório para certificados
RUN mkdir -p /var/lib/postgresql/certs

# Copiar certificados
COPY  /certs/ /var/lib/postgresql/certs/

# Copia configurações
COPY /conf/postgresql.conf /etc/postgresql/postgresql.conf
COPY /conf/pg_hba.conf /etc/postgresql/pg_hba.conf

# Permissões para certificados
RUN chown -R postgres:postgres /var/lib/postgresql/certs

# Script de inicialização
COPY init-db.sh /docker-entrypoint-initdb.d/

# Garante que o PostgreSQL tem permissões
RUN chmod 600 /var/lib/postgresql/certs/*.key 2>/dev/null || true

EXPOSE 5432