# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.synced_folder "docker/", "/dsc/docker"
end

Vagrant::Config.run do |config|
  config.vm.box = "phusion/ubuntu-14.04-amd64"
  config.vm.forward_port 7990, 7990
  config.vm.provision :puppet, :module_path => "vagrant/puppet/modules" do |puppet|
    puppet.manifests_path = "vagrant/puppet/manifests"
    puppet.manifest_file  = "default.pp"
  end
end
