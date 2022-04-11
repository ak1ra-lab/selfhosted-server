# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.0.0"

# default settings
$num_instances ||= 3
$instance_name_prefix ||= "node"
$vm_gui ||= false
$vm_memory ||= 2048
$vm_cpus ||= 2
$hostonly_mask ||= "192.168.56.%d"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "debian/bullseye64"

  # To enable `vagrant up` from WSL, we must disable synced_folder here
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # # ansible provision
  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "play.yml"
  # end

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s%02d" % [$instance_name_prefix, i] do |node|
      node.vm.hostname = vm_name

      # Create a forwarded port mapping which allows access to a specific port
      # within the machine from a port on the host machine and only allow access
      # node.vm.network "forwarded_port", guest: 22, host: 2200+i, auto_correct: true

      # Create a private network, which allows host-only access to the machine
      # using a specific IP.
      # node.vm.network "private_network", type: "dhcp"
      node.vm.network "private_network", ip: $hostonly_mask % [20+i]

      # Create a public network, which generally matched to bridged network.
      # Bridged networks make the machine appear as another physical device on
      # your network.
      # node.vm.network "public_network"

      # Provider-specific configuration so you can fine-tune various
      # backing providers for Vagrant. These expose provider-specific options.
      # Example for VirtualBox:
      node.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        vb.gui = $vm_gui

        # Customize the amount of cpu and memory on the VM:
        vb.cpus = $vm_cpus
        vb.memory = $vm_memory

        # linked clone
        vb.linked_clone = true

        # ubuntu defaults to 256 MB which is a waste of precious RAM
        vb.customize ["modifyvm", :id, "--vram", "8"]
        vb.customize ["modifyvm", :id, "--audio", "none"]

        # View the documentation for the provider you are using for more
        # information on available options.
      end
    end
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = true
  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
