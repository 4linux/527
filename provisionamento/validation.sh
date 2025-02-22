#!/bin/bash

# Variables
VAULT_SSH_HELPER="0.1.6"
SSH_HELPER_URL="https://releases.hashicorp.com/vault-ssh-helper/${VAULT_SSH_HELPER}/vault-ssh-helper_${VAULT_SSH_HELPER}_linux_amd64.zip"
DEPS_PACKAGES="vim python3 python3-pip tree wget curl unzip mlocate gem ruby rubygems ruby-dev zlib1g-dev zlib1g"
PACKAGES="git nmap dirb postgresql postgresql-client mariadb-server"

validateCommand() {
  if [ $? -eq 0 ]; then
    echo "[OK] $1"
  else
    echo "[ERROR] $1"
    exit 1
  fi
}

# Registering provision date
sudo date >> /var/log/vagrant_provision.log

# Inserting SSH key
sudo test -f /root/.ssh/id_rsa
if [ $? -eq 1 ]; then
  sudo mkdir -p /root/.ssh/ && \
    sudo cp /tmp/devsecops.pem /root/.ssh/id_rsa && \
    sudo cp /tmp/devsecops.pub /root/.ssh/authorized_keys && \
    sudo chmod 600 /root/.ssh/id_rsa
  
  validateCommand "Preparing SSH KEY"
else
  echo "[OK] SSH KEY"
fi

# Installing packages
export DEBIAN_FRONTEND=noninteractive
sudo apt-get --allow-releaseinfo-change update -qq >/dev/null 2>>/var/log/vagrant_provision.log && \
  sudo apt-get install -qq -y ${DEPS_PACKAGES} ${PACKAGES} >/dev/null 2>>/var/log/vagrant_provision.log

validateCommand "Package Installation"

# Installing Terraform
if ! command -v terraform &> /dev/null; then
  wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin/
  validateCommand "Terraform Installation"
else
  echo "[OK] Terraform"
fi

# Disabling PostgreSQL service
sudo systemctl disable postgresql &>/dev/null && \
  sudo systemctl stop postgresql &>/dev/null

validateCommand "Disabling PostgreSQL Service"

# Downloading Vault SSH Helper
if [ ! -e /usr/bin/vault-ssh-helper ]; then
  sudo wget -q -c ${SSH_HELPER_URL} -O /tmp/vault-ssh-helper.zip && \
	  sudo unzip /tmp/vault-ssh-helper.zip -d /usr/bin/ >/dev/null && \
	  sudo chmod +x /usr/bin/vault-ssh-helper

  validateCommand "Preparando Vault SSH Helper"
else
  echo "[OK] Vault SSH Helper"
fi

# Preparando Gauntlt
if [ ! -d /opt/gauntlt ]; then
  sudo git clone https://github.com/gauntlt/gauntlt.git /opt/gauntlt/ >/dev/null 2>>/var/log/vagrant_provision.log

  validateCommand "Preparando Gauntlt"
else
  echo "[OK] Gauntlt"
fi

