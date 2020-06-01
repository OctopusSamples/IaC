#! /bin/bash
configFilePath="/etc/octopus/default/tentacle-default.config"

if [[ -f $configFilePath ]]; then
  echo "Tentacle already installed"
else
  octopusServerUrl=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusServerUrl -H "Metadata-Flavor: Google")
  octopusThumbprint=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusThumbprint -H "Metadata-Flavor: Google")
  octopusApiKey=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusApiKey -H "Metadata-Flavor: Google")
  octopusMachineName=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusMachineName -H "Metadata-Flavor: Google")
  octopusSpace=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusSpace -H "Metadata-Flavor: Google")
  octopusEnvironments=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusEnvironments -H "Metadata-Flavor: Google")
  octopusRoles=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/octopusRoles -H "Metadata-Flavor: Google")
  
  externalIpAddress=$(dig +short myip.opendns.com @resolver1.opendns.com)
  echo "Found external IP: $externalIpAddress"

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

  apt-key adv --fetch-keys https://apt.octopus.com/public.key
  add-apt-repository "deb https://apt.octopus.com/ stretch main"
  
  echo "Installing listening tentacle"
  apt-get update 
  apt-get install -y tentacle

  echo "Opening listening tcp-port of 10933 for tentacle"
  ufw allow 19033/tcp

  echo "Configuring listening tentacle target"
  /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath"
  /opt/octopus/tentacle/Tentacle new-certificate --if-blank
  /opt/octopus/tentacle/Tentacle configure --port 10933 --noListen False --reset-trust --app "$applicationPath"
  /opt/octopus/tentacle/Tentacle configure --trust $octopusThumbprint
  echo "Registering the Tentacle $octopusMachineName with server $octopusServerUrl in environments '$octopusEnvironments' with roles '$octopusRoles'"
  /opt/octopus/tentacle/Tentacle register-with --server "$octopusServerUrl" --space "$octopusSpace" --apiKey "$octopusApiKey" --publicHostName "$externalIpAddress" --name "$octopusMachineName" "${envs[@]}" "${roles[@]}" --force
  /opt/octopus/tentacle/Tentacle service --install --start
  
  echo "Installing Powershell Core"
  snap install powershell --classic
  
fi