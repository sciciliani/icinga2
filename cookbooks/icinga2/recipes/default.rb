#
# Cookbook Name:: icinga2
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt'

if node["platform"] == "ubuntu"
  bash "mysql_root_pw" do
	code 'echo "mysql-server mysql-server/root_password password toor" | debconf-set-selections'
  end

  bash "mysql_root_pw_again" do
	code 'echo "mysql-server mysql-server/root_password_again password toor" | debconf-set-selections'
  end
  package "mysql-client"
  package "mysql-server"

  package "apache2"
  package "php5"
  package "php5-mysql"
  package "php5-curl"

  bash "apt-key add docker" do
    code "curl http://packages.icinga.org/icinga.key | apt-key add -"
    not_if "apt-key list | grep Icinga"
  end

  cookbook_file '/etc/apt/sources.list.d/icinga2.list' do
    source "icinga2.list"
    notifies :run, "execute[apt-get update]", :immediately
  end

  cookbook_file '/tmp/init.sh' do
    source "init.sh"
    mode 0755
  end
  
  package "icinga2"
  package "icinga2-ido-mysql"
  package "icinga-web"
  package "nagios-plugins"
  package "icingaweb2"
  package "icingacli"

  remote_directory '/etc/icingaweb2' do
    source 'icingaweb2'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  execute "icingaweb2 database initialize" do
    command "bash /tmp/init.sh"
  end

  service "apache2" do
	action :restart
  end
  service "icinga2" do
	action :restart
  end

end
