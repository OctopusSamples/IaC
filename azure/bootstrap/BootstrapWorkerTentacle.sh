#!/bin/bash
# https://linuxize.com/post/how-to-install-wildfly-on-ubuntu-18-04/

# Get the arguments that were passed
while getopts s:t:a:n:p:w:c: argument
do
  case "${argument}"
  in 
    s) serverUrl=${OPTARG};;
    t) thumbprint=${OPTARG};;
    a) apiKey=${OPTARG};;
    n) name=${OPTARG};;
    p) publicHostName=${OPTARG};;
    w) workerPoolName=${OPTARG};;
    c) spaceName=${OPTARG};;
  esac
done

configFilePath="/etc/octopus/default/tentacle-default.config"
applicationPath="/home/Octopus/Applications/"

sudo apt install --no-install-recommends gnupg curl ca-certificates apt-transport-https && \
curl -sSfL https://apt.octopus.com/public.key | sudo apt-key add - && \
sudo sh -c "echo deb https://apt.octopus.com/ stable main > /etc/apt/sources.list.d/octopus.com.list" && \
sudo apt update && sudo apt install tentacle -y

sudo /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath"
sudo /opt/octopus/tentacle/Tentacle new-certificate --if-blank
sudo /opt/octopus/tentacle/Tentacle configure --port 10933 --noListen False --reset-trust --app "$applicationPath"
sudo /opt/octopus/tentacle/Tentacle configure --trust $thumbprint
echo "Registering the Tentacle $name as a worker with server $serverUrl in $workerPoolName"
sudo /opt/octopus/tentacle/Tentacle register-worker --server "$serverUrl" --apiKey "$apiKey" --name "$name" --space "$spaceName" --publicHostName "$publicHostName" --workerpool "$workerPoolName"


# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Enable the "universe" repositories
sudo add-apt-repository universe

# Install PowerShell
sudo apt-get install -y powershell

# Install az module
echo "Installing az module ..."
pwsh -Command "& {Install-Module az -Scope AllUsers -Force}" > /tmp/azModuleInstall.log

# Install Az cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install aws cli
sudo apt-get install awscli -y

# Install and start the service
sudo /opt/octopus/tentacle/Tentacle service --install --start