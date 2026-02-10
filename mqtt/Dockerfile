FROM eclipse-mosquitto:2.0

# Copiar configuração
COPY mosquitto.conf /mosquitto/config/mosquitto.conf

# Criar diretório para certificados
RUN mkdir -p /mosquitto/certs

# Copiar certificados
COPY ./certs/mqtt /mosquitto/certs/

# Criar diretórios para dados e logs
RUN mkdir -p /mosquitto/data /mosquitto/log

# Ajustar permissões
RUN chown -R mosquitto:mosquitto /mosquitto 

EXPOSE 8883 9001

CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]