#!/bin/bash
    
#Variaveis
LOGSTASH_VERSION="7.13.1"
LOGSTASH_URL="https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VERSION}.deb"
DEPS_PACKAGES="apt-transport-https ca-certificates curl gnupg-agent software-properties-common python3 python3-pip vim openjdk-11-jre wget tree"
PACKAGES="docker-ce docker-compose"
PIP_PACKAGES="ComplexHTTPServer ansible"

# Registrando dia do Provision
sudo date >> /var/log/vagrant_provision.log

validateCommand() {
  if [ $? -eq 0 ]; then
    echo "[OK] $1"
  else
    echo "[ERROR] $1"
    exit 1
  fi
}

# Inserindo chave de SSH
sudo test -f /root/.ssh/id_rsa
if [ $? -eq 1 ]; then
  sudo mkdir -p /root/.ssh/ && \
	  sudo cp /tmp/devsecops.pem /root/.ssh/id_rsa && \
	  sudo cp /tmp/devsecops.pub /root/.ssh/authorized_keys && \
	  sudo chmod 600 /root/.ssh/id_rsa
  
  validateCommand "Preparando SSH KEY"
else
  echo "[OK] SSH KEY"
fi

# Instalando Pacotes
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq >/dev/null 2>>/var/log/vagrant_provision.log && \
	sudo apt-get install -qq -y ${DEPS_PACKAGES} ${PACKAGES} >/dev/null 2>>/var/log/vagrant_provision.log

validateCommand "Instalação de Pacotes"

# Instalando Pacotes do Python
pip3 install -q ${PIP_PACKAGES} >/dev/null 2>>/var/log/vagrant_provision.log && \
        pip3 uninstall -y docker-py >/dev/null 2>>/var/log/vagrant_provision.log

validateCommand "Pacotes Python"

#Ativando Servido do Docker
systemctl enable docker &>/dev/null && \
        systemctl start docker

validateCommand "Ativando Docker"

# Incluindo Usuário Jenkins no grupo do Docker
usermod -a -G docker jenkins

validateCommand "Configurando Usuario Jenkins"

# Baixando Instalador do Logstash
sudo test -e /root/logstash-${LOGSTASH_VERSION}.deb
if [ $? -eq 1 ]; then
  sudo wget -q -c ${LOGSTASH_URL} -O /root/logstash-${LOGSTASH_VERSION}.deb && \
	  sudo chmod 644 /root/logstash-${LOGSTASH_VERSION}.deb

  validateCommand "Preparando Instalador do Logstash"
else
  echo "[OK] Instalador do Logstash"
fi

