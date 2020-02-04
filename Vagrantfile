# -*- mode: ruby -*-
# vi: set ft=ruby :
#
servers = [
  {
    :name => "node-master",
    :type => "master",
    :box => "centos/7",
    :box_version => "1905.1",
    :eth1 => "192.168.205.10",
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "node-worker-1",
    :type => "worker",
    :box => "centos/7",
    :box_version => "1905.1",
    :eth1 => "192.168.205.11",
    :mem => "2048",
    :cpu => "2"
  },
  {
    :name => "node-worker-2",
    :type => "worker",
    :box => "centos/7",
    :box_version => "1905.1",
    :eth1 => "192.168.205.12",
    :mem => "2048",
    :cpu => "2"
  }
]

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  servers.each do |opts|
    config.vm.define opts[:name] do |node|
      config.vbguest.auto_update = false

      node.vm.box = opts[:box]
      node.vm.box_version = opts[:box_version]
      node.vm.hostname = opts[:name]
      node.vm.network :private_network, ip: opts[:eth1]

      node.vm.provider "virtualbox" do |v|
        v.name = opts[:name]
        v.customize ["modifyvm", :id, "--memory", opts[:mem]]
        v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
      end
      node.vm.provision "shell", path: "box.sh"

      if opts[:type] == "master"
        node.vm.provision "shell", path: "master.sh"
      else
        node.vm.provision "shell", path: "worker.sh"
      end
      
    end
  end
end
