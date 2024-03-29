#! /bin/bash
configFilePath="/etc/octopus/default/tentacle-default.config"

if [[ -f $configFilePath ]]; then
  echo "Tentacle already installed"
else
  octopusServerUrl=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusServerUrl -H "Metadata-Flavor: Google")
  octopusThumbprint=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusThumbprint -H "Metadata-Flavor: Google")
  octopusApiKey=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusApiKey -H "Metadata-Flavor: Google")
  octopusMachineName=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusMachineName -H "Metadata-Flavor: Google")
  workerPoolName=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/workerPoolName -H "Metadata-Flavor: Google")
  octopusSpace=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusSpace -H "Metadata-Flavor: Google")
  additionalCommands=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/additionalCommands -H "Metadata-Flavor: Google")
  
  externalIpAddress=$(curl http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
  echo "Found external IP: $externalIpAddress"

  applicationPath="/home/Octopus/Applications/"
    
  apt-key adv --fetch-keys https://apt.octopus.com/public.key
  add-apt-repository "deb https://apt.octopus.com/ stretch main"
  
  echo "Installing listening tentacle"
  apt-get update 
  apt-get install -y tentacle 

  echo "Opening listening tcp-port of 10933 for tentacle"
  ufw allow 10933/tcp
   
  echo "Configuring listening tentacle worker"
  /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath"
  /opt/octopus/tentacle/Tentacle new-certificate --if-blank
  /opt/octopus/tentacle/Tentacle configure --port 10933 --noListen False --reset-trust --app "$applicationPath"
  /opt/octopus/tentacle/Tentacle configure --trust $octopusThumbprint
  echo "Registering the Tentacle $octopusMachineName with server $octopusServerUrl in worker pool $workerPoolName"
  /opt/octopus/tentacle/Tentacle register-worker --server "$octopusServerUrl" --space "$octopusSpace" --apiKey "$octopusApiKey" --name "$octopusMachineName" --publicHostName "$externalIpAddress" --workerPool "$workerPoolName" --force
  /opt/octopus/tentacle/Tentacle service --install --start
   
  echo "Installing Powershell Core"
  snap install powershell --classic

  echo "Installing Azure CLI"
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  
  # Install Docker
  apt-get update
  apt-get -y install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  apt-get update
  apt-get -y install docker-ce docker-ce-cli containerd.io
  
  if [[ ! -z "$additionalCommands" ]]; then 
    echo "Running additional commands: $additionalCommands"
    eval "$additionalCommands"
  else
    echo "No additional commands specified to run"
  fi
fi
