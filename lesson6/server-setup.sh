#!/bin/bash

for i in {1..30}; do
    if [ -f /vagrant/keys/client_key.pub ]; then
        break
    fi
    sleep 2
done

if [ -f /vagrant/keys/client_key.pub ]; then
    mkdir -p /home/vagrant/.ssh
    
    cat /vagrant/keys/client_key.pub >> /home/vagrant/.ssh/authorized_keys
    
    chmod 700 /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
    
    cat /home/vagrant/.ssh/authorized_keys
else
    exit 1
fi
