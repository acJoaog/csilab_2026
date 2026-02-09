FROM postgres:15-alpine

# Copiar scripts
COPY ssl-config.sh /docker-entrypoint-initdb.d/
COPY init.sql /docker-entrypoint-initdb.d/

RUN chmod +x /docker-entrypoint-initdb.d/ssl-config.sh

EXPOSE 5432

# Comando padrão com SSL desabilitado inicialmente
CMD ["postgres"]