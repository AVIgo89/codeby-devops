#!/bin/bash

mkdir -p /home/vagrant/.ssh

ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -N "" -C "vagrant@client"

mkdir -p /vagrant/keys

cp /home/vagrant/.ssh/id_rsa.pub /vagrant/keys/client_key.pub

chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub
chown -R vagrant:vagrant /home/vagrant/.ssh

cat > /home/vagrant/.ssh/config << 'SSHCONFIG'
Host server
    HostName 192.168.100.10
    User vagrant
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
SSHCONFIG

chmod 600 /home/vagrant/.ssh/config
chown vagrant:vagrant /home/vagrant/.ssh/config

ls -la /home/vagrant/.ssh/
