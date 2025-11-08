# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Use Ubuntu 20.04 LTS (Focal Fossa)
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = ">= 20231026.0.0"

  # VM Configuration
  config.vm.hostname = "wordpress-local"
  
  # Network Configuration
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443
  config.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh"

  # VM Resources
  config.vm.provider "virtualbox" do |vb|
    vb.name = "wordpress-ubuntu20-vm"
    vb.memory = "2048"
    vb.cpus = 2
    vb.gui = false
    
    # Enable virtualization features
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # Synced folders
  config.vm.synced_folder ".", "/vagrant", disabled: false
  
  # SSH Configuration for Ansible
  config.vm.provision "shell", inline: <<-SHELL
    # Update system
    apt-get update
    
    # Install basic packages for Ubuntu 20.04
    apt-get install -y curl wget git vim net-tools software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    
    # Create ansible user
    useradd -m -s /bin/bash ansible
    usermod -aG sudo ansible
    
    # Set up SSH for ansible user
    mkdir -p /home/ansible/.ssh
    chmod 700 /home/ansible/.ssh
    
    # Allow ansible user to sudo without password
    echo "ansible ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    
    # Set up SSH key (you'll copy your key later)
    touch /home/ansible/.ssh/authorized_keys
    chmod 600 /home/ansible/.ssh/authorized_keys
    chown -R ansible:ansible /home/ansible/.ssh
    
    # Enable password authentication temporarily (optional)
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh
    
    # Set password for ansible user (optional, for initial setup)
    echo "ansible:ansible123" | chpasswd
    
    # Install Python 3 (required for Ansible)
    apt-get install -y python3 python3-pip
    
    # Create Python 3 symlink for Ansible compatibility
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1
    
    echo "VM setup completed!"
    echo "OS: Ubuntu 20.04 LTS"
    echo "VM IP: 192.168.56.10"
    echo "SSH: vagrant ssh or ssh ansible@192.168.56.10"
    echo "Default user: vagrant, Ansible user: ansible (password: ansible123)"
  SHELL
end