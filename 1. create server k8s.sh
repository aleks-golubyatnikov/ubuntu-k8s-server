#!/bin/sh

# Azure CLI 
# Script creates virtual machine for testing k8s:
#  --Hardware requirements:
#    - 2x CPU;
#    - 2GB RAM;
#  -- OS requirements:
#      - UbuntuLTS 18.04 
#  -- Architecture:
#     - server #1: vm-k8s-server-01 [10.0.1.10];

# !!!
#You would need to log out and log back in so that your group membership is re-evaluated
# Then run minikube: minikube start

az group create \
--name RG-k8s-server \
--location centralus

az network vnet create \
--resource-group RG-k8s-server \
--name AZ-k8s-vNET \
--address-prefix 10.0.0.0/16 \
--subnet-name k8s-SUBNET \
--subnet-prefix 10.0.0.0/24

az network vnet subnet create \
--address-prefixes 10.0.1.0/24 \
--name cluster-SUBNET \
--vnet-name AZ-k8s-vNET \
--resource-group RG-k8s-server

# vm-k8s-server-01
# NSG for server #1
az network nsg create \
  --resource-group RG-k8s-server \
  --name NSG-SERVER-01

az network nsg rule create \
  --resource-group RG-k8s-server \
  --name NSG-SERVER-01-ALLOW-HTTP \
  --nsg-name NSG-SERVER-01 \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 80 \
  --access allow \
  --priority 200

az network nsg rule create \
  --resource-group RG-k8s-server \
  --name NSG-SERVER-01-ALLOW-SSH \
  --nsg-name NSG-SERVER-01\
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 22 \
  --access allow \
  --priority 100

az network nsg rule create \
  --resource-group RG-k8s-server \
  --name NSG-SERVER-01-ALLOW-HTTP-8080 \
  --nsg-name NSG-SERVER-01 \
  --protocol tcp \
  --direction inbound \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix 'VirtualNetwork' \
  --destination-port-range 8080 \
  --access allow \
  --priority 210

az network public-ip create \
  --resource-group RG-k8s-server \
  --name PIP-SERVER-01 \
  --sku Standard \
  --version IPv4

az network nic create \
--resource-group RG-k8s-server \
--name server-01-NIC \
--subnet cluster-SUBNET \
--network-security-group NSG-SERVER-01 \
--private-ip-address 10.0.1.10 \
--public-ip-address PIP-SERVER-01 \
--vnet-name AZ-k8s-vNET

# Deploy server #1
az vm create \
  --resource-group RG-k8s-server \
  --name vm-k8s-server-01 \
  --admin-username golubyatnikov \
  --admin-password Upgrade-2035UP \
  --image UbuntuLTS \
  --nics server-01-NIC \
  --size Standard_B2ms  

# Run scripts - server #1   
az vm extension set \
  --publisher Microsoft.Azure.Extensions \
  --version 2.0 \
  --name CustomScript \
  --vm-name vm-k8s-server-01 \
  --resource-group RG-k8s-server \
  --settings '{"commandToExecute":"apt-get -y update && apt-get -y install apache2 && echo k8s: vm-k8s-server-01 > /var/www/html/index.html && mkdir /home/init-server && chmod 0777 /home/init-server && git clone https://github.com/aleks-golubyatnikov/ubuntu-k8s-server.git /home/init-server && chmod 0755 /home/init-server/run.sh && cd /home/init-server && bash run.sh"}'
  