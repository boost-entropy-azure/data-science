#!/usr/bin/env bash

# install unzip
apt install --assume-yes unzip

# download terraform binary
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip

# unzip terraform binary
unzip terraform_0.12.24_linux_amd64.zip

# install terraform
sudo mv terraform /usr/local/bin

# clone data_science repo
mkdir /home/vagrant/sandbox
cd /home/vagrant/sandbox
git clone https://github.com/chesapeaketechnology/data-science.git
sudo chown -R vagrant /home/vagrant/sandbox
