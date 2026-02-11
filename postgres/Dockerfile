FROM postgres:15-alpine

# Instalações necessárias
RUN apk add --no-cache openssl

# Copia certificados
COPY certs /etc/postgresql/certs/

# Copia entrypoint personalizado
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Scripts de inicialização
COPY init-db.sh /docker-entrypoint-initdb.d/
COPY setup-ssl.sh /docker-entrypoint-initdb.d/01-setup-ssl.sh
RUN chmod +x /docker-entrypoint-initdb.d/*.sh

# NÃO faz chown aqui - será feito no entrypoint como root

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["postgres"]