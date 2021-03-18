# Represents the configuration of one VM. This class is necessary to provide
# per-VM variables in the closure block, due to when Vagrant evaluates the
# closure. A simple for loop in the main config closure would define three VMs,
# but the variables in the per-VM closures would be resolved only after the
# loop had completed. By creating one instance of this class per VM, each block
# gets it's own set of variables (from the class instance).
class Cfg
  def initialize(i)
    @name = "node-#{i}"
    @cephdisk = ".vagrant/machines/ceph-#{@name}.vdi"
    @primary = i == 1
    @ip = "192.168.33.#{10 + i}"
  end

  def configure(config)
    config.vm.define @name, primary: @primary do |v|
      v.vm.hostname = @name
      v.vm.provider :virtualbox do |vb|
        unless File.exist?(@cephdisk)
          vb.customize ['createhd', '--filename', @cephdisk, '--size', 8*1024] # 8 GB
        end
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', @cephdisk]
      end
      v.vm.network "private_network", ip: @ip
      v.vm.provision "shell", path: "bin/provision-k3s", args: [@ip, @primary.to_s]
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
    # Create config object only once. Vagrant will evalate the config block
    # multiple times, but we don't want to add configuration on every
    # evaluation.
    if not cfgs[i]
      c = Cfg.new(i)
      c.configure(config)
      cfgs[i] = c
    end
  end
end
