#!/bin/bash
DateTime=$(date +"%Y/%m/%d %H:%M:%S")
echo "$DateTime start installation..." >> instalation.log

#Docker
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release 2>&1 >> instalation.log 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >> instalation.log 2>&1
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update >> instalation.log 2>&1
sudo apt-get -y install docker-ce docker-ce-cli containerd.io >> instalation.log 2>&1

sudo groupadd docker >> instalation.log 2>&1
sudo usermod -aG docker golubyatnikov >> instalation.log 2>&1

#kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl >> instalation.log 2>&1

#Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb >> instalation.log 2>&1

DateTime=$(date +"%Y/%m/%d %H:%M:%S")
echo "$DateTime end installation..." >> instalation.log

#minikube start


