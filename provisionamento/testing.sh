#!/bin/bash

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Variaveis
DEPS_PACKAGES="unzip wget nodejs vim tree python3 python3-pip python3-setuptools xorg-x11-xauth langpacks-en glibc-all-langpacks"
PACKAGES="git openscap-scanner scap-security-guide scap-workbench owasp-zap"
GUI_PACKAGES="glx-utils mesa-dri-drivers spice-vdagent xorg-x11-drivers xorg-x11-server-Xorg xorg-x11-utils xorg-x11-xinit xterm fluxbox"
PIP_PACKAGES="ComplexHTTPServer zap-cli-v2"
# MIRROR_CENTOS="ufscar"

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

# Inserindo chave SSH
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

# Altera os repositorio do Centos8 pra o mirror Vault, pois foi depreciado os mirros oficiais.
sudo sed -i 's/^mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Ajustanto repo Epel-8. countme não é mais permitido.
sudo sed -i 's/^countme=1/#&/' /etc/yum.repos.d/epel*.repo

# Limpando Cache de repositorio
sudo dnf clean all

# Instalando NodeJS 14
sudo curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo sed -i 's/^failovermethod=priority/#&/' /etc/yum.repos.d/nodesource-el8.repo

# Atualizando RPM
sudo dnf update rpm -q -y


# # Solução temporaria para EOL Centos 8
# sudo rpm -Uhv --nodeps http://mirror.${MIRROR_CENTOS}.br/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-8-3.el8.noarch.rpm http://mirror.${MIRROR_CENTOS}.br/centos/8-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-3.el8.noarch.rpm http://mirror.${MIRROR_CENTOS}.br/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-release-8.5-3.el8.noarch.rpm

# Instalando Pacotes
sudo dnf install -y ${DEPS_PACKAGES} ${PACKAGES} ${GUI_PACKAGES}

validateCommand "Instalação de Pacotes"

# Instalando Pacotes Python
sudo pip3 install -q ${PIP_PACKAGES}

validateCommand "Pacotes Python"

# Configurando archerycli
sudo python3 -m pip install archerysec-cli

validateCommand "Instala Archerysec"

# Criando Link Simbolico OWASP ZAP
if [ ! -e /usr/bin/zap.sh ]; then
  sudo ln -s /usr/share/owasp-zap/zap.sh /usr/bin/
  sudo ln -s /usr/local/bin/zap-cli-v2 /usr/bin/
  validateCommand "Conf. Binário OWASP ZAP"
else
  echo "[OK] Binário OWASP ZAP"
fi

# Configuração do Xauthority para uso do SSH X11 Forwarding quando possivel
sudo grep Xauthority /root/.bashrc &>/dev/null
if [ $? -eq 1 ]; then
  sudo echo 'sudo cp /home/vagrant/.Xauthority /root/.Xauthority' >> /root/.bashrc && \
          sudo echo "LANG=en_US.UTF-8" >> /etc/environment && \
          sudo echo "LC_ALL=en_US.UTF-8" >> /etc/environment
  validateCommand "Configurando Xauthority"
else
  echo "[OK] Xauthority"
fi

# Configuração do OpenScap para CentOS 8
SG_PATH="/usr/share/xml/scap/ssg/content"
cp /opt/openscap/cpe/*.xml /usr/share/openscap/cpe/
for FILE in $(ls $SG_PATH/ssg-rhel8-*);
  do
    if [ ! -e "${FILE//rhel8/centos8}" ]; then
      sudo cp $FILE ${FILE//rhel8/centos8};
      sudo sed -i \
              -e 's|idref="cpe:/o:redhat:enterprise_linux|idref="cpe:/o:centos:centos|g' \
              -e 's|ref_id="cpe:/o:redhat:enterprise_linux|ref_id="cpe:/o:centos:centos|g' \
              ${FILE//rhel8/centos8};
    fi
  done
validateCommand "Configuração do OpenSCAP"

sudo dnf install -y fontconfig java-17-openjdk
sudo alternatives --set java java-17-openjdk.x86_64
sudo dnf upgrade -y jenkins
validateCommand "Atualiza Jenkins"

sudo systemctl restart jenkins
validateCommand "Reinicia Jenkins"
