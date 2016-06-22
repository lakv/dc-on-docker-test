#!/bin/bash

set -e

# Preparing Apt
[ ! -f "/etc/apt/sources.list.d/docker.list" ] && \
    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update

# Firefox
if [ ! -f "/usr/bin/firefox" ]
then
    apt-get install --force-yes -y firefox
fi

# Docker
if [ ! -f "/usr/bin/docker" ]
then
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    apt-get install --force-yes -y docker-engine=1.10.3-0~trusty
    usermod -a -G docker vagrant
fi

# Ansible
if [ ! -f "/usr/bin/ansible-playbook" ]
then
    cache_dir="/home/vagrant"
    ansible_src="${cache_dir}/ansible"
    mkdir -p $cache_dir
    apt-get install --force-yes -y git-core libssl-dev libffi-dev python-dev python-pip
    pip install paramiko PyYAML Jinja2 httplib2 six
    if [ -d "$ansible_src" ]
    then
        cd $ansible_src
        git fetch origin devel
        git reset --hard origin/devel
        git pull
        git submodule update --init --recursive
    else
        cd $cache_dir
        git clone https://github.com/keinohguchi/ansible --recursive
    fi

    cd $ansible_src && {
        source ./hacking/env-setup
        make install
    }
fi

# Generating SSH Key
if [ ! -f /home/vagrant/.ssh/id_rsa ]
then
    su -c 'cp /vagrant/utils/id_rsa /vagrant/utils/id_rsa.pub /home/vagrant/.ssh/' vagrant
    chmod 0600 /vagrant/utils/id_rsa
    chmod 0600 /vagrant/utils/id_rsa.pub
    su -c 'cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys' vagrant
fi

exit 0
