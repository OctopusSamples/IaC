#!/bin/bash
serverUrl="#{Samples.Octopus.Url}"
serverCommsPort="10943"
apiKey="#{Samples.Octopus.Api.Key}"
name=$HOSTNAME
configFilePath="/etc/octopus/default/tentacle-default.config"
applicationPath="/home/Octopus/Applications/"
workerPool="#{Octopus.Action[Get Samples Spaces].Output.WorkerPoolName}"
machinePolicy="Default Machine Policy"
space="#{Octopus.Action[Get Samples Spaces].Output.InitialSpaceName}"

# Install basic utilities
sudo apt-get update
sudo apt install apt-transport-https ca-certificates curl software-properties-common wget -y

# Install Tentacle
sudo apt-key adv --fetch-keys "https://apt.octopus.com/public.key"
sudo add-apt-repository "deb https://apt.octopus.com/ focal main"
sudo apt-get update
sudo apt-get install tentacle -y

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Download the Microsoft repository GPG keys
wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

# Install AWS CLI
sudo apt-get install awscli -y

# Install .NET 6
sudo apt-get install dotnet-sdk-6.0 -y

# Pull worker tools image
sudo docker pull #{Project.Docker.WorkerToolImage}:#{Project.Docker.WorkerToolImageTag}

# Configure and register worker
sudo /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath" --instance "$name"
sudo /opt/octopus/tentacle/Tentacle new-certificate --if-blank
sudo /opt/octopus/tentacle/Tentacle configure --noListen True --reset-trust --app "$applicationPath"
echo "Registering the worker $name with server $serverUrl"
sudo /opt/octopus/tentacle/Tentacle service --install --start
sudo /opt/octopus/tentacle/Tentacle register-worker --server "$serverUrl" --apiKey "$apiKey" --name "$name"  --comms-style "TentacleActive" --server-comms-port $serverCommsPort --workerPool "$workerPool" --policy "$machinePolicy" --space "$space"
sudo /opt/octopus/tentacle/Tentacle service --restart