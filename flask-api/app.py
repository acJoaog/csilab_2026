import ssl
import paho.mqtt.client as mqtt
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_jwt_extended import JWTManager, create_access_token, jwt_required
from models import db, User, Device, DeviceMessage
import os
from datetime import timedelta

app = Flask(__name__)
CORS(app)

# Configurações
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'postgresql://iot_user:iot_password_secure@postgres-db:5432/iot_database')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET', 'super-secret-change-in-production')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)

# Inicializar extensões
db.init_app(app)
jwt = JWTManager(app)

# Configuração MQTT
mqtt_broker = os.getenv('MQTT_BROKER', 'mqtt-broker')
mqtt_port = int(os.getenv('MQTT_PORT', 8883))
ca_path = os.getenv('SSL_CA_PATH', '/app/certs/ca.crt')

# Cliente MQTT
mqtt_client = mqtt.Client()

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Conectado ao broker MQTT com sucesso")
        # Subscrever a tópicos de controle
        client.subscribe("devices/+/control")
    else:
        print(f"Falha na conexão MQTT: {rc}")

def on_message(client, userdata, msg):
    print(f"Mensagem recebida: {msg.topic} {msg.payload.decode()}")
    # Aqui você pode processar mensagens de controle dos dispositivos
    # e atualizar o banco de dados conforme necessário

def setup_mqtt():
    """Configurar cliente MQTT com TLS"""
    try:
        mqtt_client.on_connect = on_connect
        mqtt_client.on_message = on_message
        
        # Configurar TLS
        mqtt_client.tls_set(
            ca_certs=ca_path,
            certfile='/app/certs/server.crt',
            keyfile='/app/certs/server.key',
            cert_reqs=ssl.CERT_REQUIRED,
            tls_version=ssl.PROTOCOL_TLSv1_2
        )
        
        mqtt_client.connect(mqtt_broker, mqtt_port, 60)
        mqtt_client.loop_start()
        return True
    except Exception as e:
        print(f"Erro ao configurar MQTT: {e}")
        return False

# Rotas da API
@app.route('/')
def index():
    return jsonify({
        "message": "IoT API",
        "status": "online",
        "version": "1.0.0"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/api/auth/login', methods=['POST'])
def login():
    """Autenticação de usuário"""
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    # Em produção, usar bcrypt para verificar senha
    user = User.query.filter_by(username=username).first()
    
    if user and user.check_password(password):
        access_token = create_access_token(identity=user.id)
        return jsonify({
            "access_token": access_token,
            "user": {
                "id": user.id,
                "username": user.username,
                "email": user.email
            }
        }), 200
    
    return jsonify({"error": "Credenciais inválidas"}), 401

@app.route('/api/devices', methods=['GET'])
@jwt_required()
def get_devices():
    """Listar dispositivos do usuário"""
    user_id = get_jwt_identity()
    devices = Device.query.filter_by(user_id=user_id).all()
    
    return jsonify({
        "devices": [{
            "id": d.id,
            "device_id": d.device_id,
            "device_name": d.device_name,
            "device_type": d.device_type,
            "status": d.status,
            "last_seen": d.last_seen
        } for d in devices]
    }), 200

@app.route('/api/devices/<device_id>/control', methods=['POST'])
@jwt_required()
def control_device(device_id):
    """Enviar comando para dispositivo"""
    user_id = get_jwt_identity()
    data = request.get_json()
    
    # Verificar se dispositivo pertence ao usuário
    device = Device.query.filter_by(device_id=device_id, user_id=user_id).first()
    if not device:
        return jsonify({"error": "Dispositivo não encontrado"}), 404
    
    # Publicar comando MQTT
    topic = f"devices/{device_id}/control"
    command = data.get('command', {})
    
    try:
        mqtt_client.publish(topic, str(command), qos=1)
        
        # Registrar comando no banco
        message = DeviceMessage(
            device_id=device_id,
            topic=topic,
            message=str(command),
            qos=1
        )
        db.session.add(message)
        db.session.commit()
        
        return jsonify({
            "success": True,
            "message": "Comando enviado",
            "device": device_id,
            "command": command
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/devices/<device_id>/messages', methods=['GET'])
@jwt_required()
def get_device_messages(device_id):
    """Obter histórico de mensagens do dispositivo"""
    user_id = get_jwt_identity()
    
    # Verificar se dispositivo pertence ao usuário
    device = Device.query.filter_by(device_id=device_id, user_id=user_id).first()
    if not device:
        return jsonify({"error": "Dispositivo não encontrado"}), 404
    
    # Obter mensagens (últimas 100)
    messages = DeviceMessage.query.filter_by(device_id=device_id)\
        .order_by(DeviceMessage.timestamp.desc())\
        .limit(100).all()
    
    return jsonify({
        "device": device_id,
        "messages": [{
            "id": m.id,
            "topic": m.topic,
            "message": m.message,
            "timestamp": m.timestamp.isoformat() if m.timestamp else None
        } for m in messages]
    }), 200

@app.route('/api/users/register', methods=['POST'])
def register():
    """Registrar novo usuário"""
    data = request.get_json()
    
    # Validar dados
    if not all(k in data for k in ['username', 'email', 'password']):
        return jsonify({"error": "Dados incompletos"}), 400
    
    # Verificar se usuário já existe
    if User.query.filter_by(username=data['username']).first():
        return jsonify({"error": "Usuário já existe"}), 409
    
    if User.query.filter_by(email=data['email']).first():
        return jsonify({"error": "Email já registrado"}), 409
    
    # Criar novo usuário
    new_user = User(
        username=data['username'],
        email=data['email']
    )
    new_user.set_password(data['password'])
    
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({
        "message": "Usuário criado com sucesso",
        "user": {
            "id": new_user.id,
            "username": new_user.username,
            "email": new_user.email
        }
    }), 201

if __name__ == '__main__':
    with app.app_context():
        # Criar tabelas
        db.create_all()
        
        # Configurar MQTT
        if setup_mqtt():
            print("MQTT configurado com sucesso")
        else:
            print("Aviso: MQTT não configurado")
    
    # Executar aplicação com SSL
    ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    ssl_context.load_cert_chain(
        '/app/certs/server.crt',
        '/app/certs/server.key'
    )
    
    # Para produção, use gunicorn:
    # gunicorn -w 4 -b 0.0.0.0:8443 --certfile=/app/certs/server.crt --keyfile=/app/certs/server.key app:app
    
    app.run(
        host='0.0.0.0',
        port=8443,
        ssl_context=ssl_context,
        debug=False
    )