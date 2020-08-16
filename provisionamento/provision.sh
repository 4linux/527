#!/bin/bash

PLAYBOOK=$1

lsb_dist=""
if [ -r /etc/os-release ]; then
  lsb_dist="$(. /etc/os-release && echo "$ID")"
fi
echo "$lsb_dist"

if [ "$lsb_dist" == "centos" ]; then

  yum -q install epel-release -y >/dev/null && echo "[OK] EPEL RELEASE"
  yum -q install ansible -y >/dev/null && echo "[OK] ANSIBLE"

elif [ "$lsb_dist" == "debian" ]; then

  apt-get update -qq >/dev/null && apt-get install software-properties-common gnupg -y -qq >/dev/null && echo "[OK] SOFTWARE PROPERTIES COMMON"
  apt-add-repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" && echo "[OK] ANSIBLE REPOSITORY"
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 >/dev/null && echo "[OK] ANSIBLE KEY"
  apt-get update -qq >/dev/null && echo "[OK] UPDATE REPOSITORY"
  apt-get install -qq ansible -y >/dev/null && echo "[OK] ANSIBLE"

else
  echo "Script Suportado apenas para CentOS e Debian"
  exit 1
fi

if [ ! -f /root/.ssh/id_rsa ]; then
  mkdir -p /root/.ssh/ && \
  cat /vagrant/keys/devsecops.pem > /root/.ssh/id_rsa && \
  cat /vagrant/keys/devsecops.pub > /root/.ssh/authorized_keys && \
  chmod 600 /root/.ssh/id_rsa && \
  echo "[OK] SSH KEY"
fi

if [ ! -z "$PLAYBOOK" ]; then
  ansible-playbook /vagrant/$PLAYBOOK
fi
