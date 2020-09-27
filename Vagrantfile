# -*- mode: ruby -*-
# vi: set ft=ruby :
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
require 'yaml'
secmachines = YAML.load_file("machines.yml")

Vagrant.configure("2") do |config|
  secmachines.each do |machines|
    config.vm.define machines["name"] do |server|
      server.vm.hostname = machines["name"]
      server.vm.box = machines["box"]
      server.vm.box_check_update = false
      server.vm.network "private_network", ip: machines["ip"], dns: "8.8.8.8" 

      server.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--groups", "/DevSecOps"]
        vb.memory = machines["memory"]
        vb.cpus = machines["cpus"]
        vb.name = machines["name"]
      end

      server.vm.provision "file", source: "keys/devsecops.pem", destination: "/tmp/"
      server.vm.provision "file", source: "keys/devsecops.pub", destination: "/tmp/"
      server.vm.provision "shell", path: machines["script"]
    end
  end
end
