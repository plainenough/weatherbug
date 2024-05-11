#!/usr/bin/env bash
set -eo pipefail

echo "Installing Utilities"

echo "Setup hachicorp repository...."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Update and install terraform and other tools...."
sudo apt update && sudo apt install -y terraform curl unzip

echo "Install AWScliv2"
sudo apt-get install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf ./aws awscliv2.zip

echo "Setting up kubectl...."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.3/2024-04-19/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "Setting up helm...."
wget -O helm.tar.gz https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz
tar -zxvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 kubectl helm.tar.gz

echo "Done installing utilities...."