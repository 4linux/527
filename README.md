Laboratório - 527 - DevSecOps
=============================

Repositório para armazenar o Laboratório do curso de DevSecOps da [4Linux][1]

Dependências
------------

Para a criação do laboratório é necessário ter pré instalado os seguintes softwares:

* [Git][2]
* [VirtualBox][3]
* [Ansible][4]
* [Vagrant][5]

> Para o máquinas com Windows aconselhamos, se possível, que as instalações sejam feitas pelo gerenciador de pacotes **[Cygwin][6]**.

> Para as máquinas com MAC OS aconselhamos, se possível, que as instalações sejam feitas pelo gerenciador de pacotes **brew**.

Laboratório
-----------

O Laboratório será criado utilizando o [Vagrant][7]. Ferramenta para criar e gerenciar ambientes virtualizados (baseado em Inúmeros providers) com foco em automação.

Nesse laboratórios, que está centralizado no arquivo [Vagrantfile][8], serão criadas 4 maquinas com as seguintes características:

Nome       | vCPUs | Memoria RAM | IP            | Box¹           | Script de Provisionamento²
---------- |:-----:|:-----------:|:-------------:|:---------------:| -----------------------------
testing    | 1     | 3072MB      | 192.168.77.10 | centos/7        | [provisionamento/jenkins.yml][9]
automation | 1     | 3072MB      | 192.168.77.20 | debian/buster64 | [provisionamento/docker.yml][10]
logging    | 1     | 4092MB      | 192.168.77.30 | centos/7        | [provisionamento/x.yml][11]
validation | 1     | 2048MB      | 192.168.77.40 | debian/buster64 | [provisionamento/xx.yml][12]

> **¹**: Box é a forma como o vagrant chama as imagens do sistema operacional utilizado

> **²**: Para o Script de Provisionamento estamos utilizando o Ansible

Criação do Laboratório 
----------------------

Para criar o laboratório é necessário fazer o `git clone` desse repositório e, dentro da pasta baixada realizar a execução do `vagrant up`, conforme abaixo:

```bash
git clone https://github.com/4linux/527
cd 527/
vagrant up
```

_O Laboratório **pode demorar alguns minutos**, dependendo da conexão de internet, para ficar totalmente preparado._

Por fim, para melhor utilização, abaixo há alguns comandos básicos do vagrant para gerencia das máquinas virtuais.

Comandos                | Descrição
:----------------------:| ---------------------------------------
`vagrant init`          | Gera o VagrantFile
`vagrant box add <box>` | Baixar imagem do sistema
`vagrant box status`    | Verificar o status dos boxes criados
`vagrant up`            | Cria/Liga as VMs baseado no VagrantFile
`vagrant provision`     | Provisiona mudanças logicas nas VMs
`vagrant status`        | Verifica se VM estão ativas ou não.
`vagrant ssh <vm>`      | Acessa a VM
`vagrant ssh <vm> -c <comando>` | Executa comando via ssh
`vagrant reload <vm>`   | Reinicia a VM
`vagrant halt`          | Desliga as VMs

> Para maiores informações acesse a [Documentação do Vagrant][13]

[1]: https://4linux.com.br
[2]: https://git-scm.com/downloads
[3]: https://www.virtualbox.org/wiki/Downloads
[4]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
[5]: https://www.vagrantup.com/downloads
[6]: https://cygwin.com/install.html
[7]: https://www.vagrantup.com/
[8]: ./Vagrantfile
[9]: ./provisionamento/jenkins.yml
[10]: ./provisionamento/docker.yml
[11]: ./provisionamento/x.yml
[12]: ./provisionamento/xx.yml
[13]: https://www.vagrantup.com/docs