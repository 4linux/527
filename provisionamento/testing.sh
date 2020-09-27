#!/bin/bash
    
#Variaveis
DEPS_PACKAGES="unzip wget nodejs vim tree python3 python3-pip python3-setuptools xorg-x11-xauth " 
PACKAGES="git openscap-scanner scap-security-guide scap-workbench owasp-zap"
GUI_PACKAGES="glx-utils mesa-dri-drivers spice-vdagent xorg-x11-drivers xorg-x11-server-Xorg xorg-x11-utils xorg-x11-xinit xterm fluxbox"
PIP_PACKAGES="ComplexHTTPServer"

validateCommand() {
  if [ $? -eq 0 ]; then
    echo "[OK] $1"
  else
    echo "[ERROR] $1"
    exit 1
  fi
}

# Registrando dia do Provision
sudo date >> /var/log/vagrant_provision.log

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
sudo yum install -q -y ${DEPS_PACKAGES} ${PACKAGES} ${GUI_PACKAGES} >/dev/null 2>>/var/log/vagrant_provision.log

validateCommand "Instalação de Pacotes"

# Instalando Pacotes Python
pip3 install -q ${PIP_PACKAGES} >/dev/null 2>>/var/log/vagrant_provision.log

validateCommand "Pacotes Python"

# Criando Link Simbolico OWASP ZAP
if [ ! -e /usr/bin/zap.sh ]; then

  ln -s /usr/share/owasp-zap/zap.sh /usr/bin/
  validateCommand "Conf. Binário OWASP ZAP"
else
  echo "[OK] Binário OWASP ZAP"
fi

# Configuração do Xauthority para uso do SSH X11 Forwarding quando possivel
sudo grep Xauthority /root/.bashrc
if [ $? -eq 1 ]; then
  sudo echo 'sudo cp /home/vagrant/.Xauthority /root/.Xauthority' >> /root/.bashrc
  validateCommand "Configurando Xauthority"
else
  echo "[OK] Xauthority"
fi
