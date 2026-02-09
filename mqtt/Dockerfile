FROM eclipse-mosquitto:2.0

# Copiar configuração
COPY mosquitto.conf /mosquitto/config/mosquitto.conf

# Criar diretório para certificados
RUN mkdir -p /mosquitto/certs

EXPOSE 8883 9001

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]