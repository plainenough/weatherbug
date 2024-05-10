#!/usr/bin/env bash
set -eo pipefail

echo "Installing Utilities"

echo "Setup hachicorp repository...."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Update and install terraform...."
sudo apt update && sudo apt install -y terraform

echo "Done installing utilities...."