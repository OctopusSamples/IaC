#! /bin/bash
configFilePath="/etc/octopus/default/tentacle-default.config"

if [[ -f $configFilePath ]]; then
  echo "Tentacle already installed"
else
  octopusServerUrl=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusServerUrl -H "Metadata-Flavor: Google")
  octopusSpace=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusSpace -H "Metadata-Flavor: Google")
  octopusApiKey=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusApiKey -H "Metadata-Flavor: Google")
  workerPoolName=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/workerPoolName -H "Metadata-Flavor: Google")
  octopusMachineName=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusMachineName -H "Metadata-Flavor: Google")
  serverCommsPort=10943            
  applicationPath="/home/Octopus/Applications/"
    
  apt-key adv --fetch-keys https://apt.octopus.com/public.key
  add-apt-repository "deb https://apt.octopus.com/ stretch main"
  apt-get update
   
  apt-get install tentacle

  /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath"
  /opt/octopus/tentacle/Tentacle new-certificate --if-blank
  /opt/octopus/tentacle/Tentacle configure --noListen True --reset-trust --app "$applicationPath"
  echo "Registering the Tentacle $octopusMachineName with server $octopusServerUrl in worker pool $workerPoolName"
  /opt/octopus/tentacle/Tentacle register-worker --server "$octopusServerUrl" --space "$octopusSpace" --apiKey "$octopusApiKey" --name "$octopusMachineName" --workerPool "$workerPoolName" --comms-style "TentacleActive" --server-comms-port $serverCommsPort --force
  /opt/octopus/tentacle/Tentacle service --install --start
  
  sudo apt-get install -y curl apt-transport-https
  
  echo "Installing Powershell core"
  snap install powershell --classic

  echo "Installing Java (Open-JDK)"
  apt-get update
  sudo apt install default-jdk -y
  
fi