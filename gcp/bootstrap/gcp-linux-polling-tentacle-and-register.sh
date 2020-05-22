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
  octopusEnvironments=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusEnvironments -H "Metadata-Flavor: Google")
  octopusRoles=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusRoles -H "Metadata-Flavor: Google")
  
  serverCommsPort=10943            
  applicationPath="/home/Octopus/Applications/"

  envs=()  
  IFS=', ' read -ra OCTO_ENVS <<< "${octopusEnvironments}"
  for environment in "${OCTO_ENVS[@]}"
  do
      envs+=("--env=${environment}")
  done

  roles=()  
  IFS=', ' read -ra OCTO_ROLES <<< "${octopusRoles}"
  for role in "${OCTO_ROLES[@]}"
  do
      roles+=("--role=${role}")
  done

  environment="Test"  # The environment to register the Tentacle in
  role="web server"   # The role to assign to the Tentacle

  apt-key adv --fetch-keys https://apt.octopus.com/public.key
  add-apt-repository "deb https://apt.octopus.com/ stretch main"
  apt-get update
  apt-get install tentacle

  /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath"
  /opt/octopus/tentacle/Tentacle new-certificate --if-blank
  /opt/octopus/tentacle/Tentacle configure --noListen True --reset-trust --app "$applicationPath"
  echo "Registering the Tentacle $octopusMachineName with server $octopusServerUrl in environments '$octopusEnvironments' with roles '$octopusRoles'"
  /opt/octopus/tentacle/Tentacle register-with --server "$octopusServerUrl" --space "$octopusSpace" --apiKey "$octopusApiKey" --name "$name" "${envs[@]}" "${roles[@]}" --comms-style "TentacleActive" --server-comms-port $serverCommsPort
  /opt/octopus/tentacle/Tentacle service --install --start
  
  sudo apt-get install -y curl apt-transport-https
  
  echo "Installing Powershell core"
  snap install powershell --classic
  
fi