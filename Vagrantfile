class Cfg
  def initialize(i, config)
    @name = "node-#{i}"
    @cephdisk = ".vagrant/machines/ceph-#{@name}.vdi"
    @primary = i == 1
    @config = config
    @ip = "192.168.33.#{10 + i}"
  end

  def configure()
    @config.vm.define @name, primary: @primary do |v|
      v.vm.hostname = @name
      v.vm.provider :virtualbox do |vb|
        unless File.exist?(@cephdisk)
          vb.customize ['createhd', '--filename', @cephdisk, '--size', 500 * 1024]
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', @cephdisk]
      end
      v.vm.network "private_network", ip: @ip
      v.vm.provision "shell", path: "provision.sh", args: [@ip]
    end
  end
end

cfgs = []

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-buster64"
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
  end

  for i in 1..3
    if not cfgs[i]
      c = Cfg.new(i, config)
      c.configure()
      cfgs[i] = c
    end
  end

  config.vm.provision "shell", inline: <<-SHELL
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
  SHELL

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
