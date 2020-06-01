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
  wildflyUser=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/wildflyUser -H "Metadata-Flavor: Google")
  wildflyPass=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/wildflyPass -H "Metadata-Flavor: Google")
  wildflyPort=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/wildflyPort -H "Metadata-Flavor: Google")
  redirectHttpToWildfly=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/redirectHttpToWildfly -H "Metadata-Flavor: Google")

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

  echo "Installing JDK"
  sudo apt install default-jdk -y

  # Install Wildfly
  sudo groupadd -r wildfly
  sudo useradd -r -g wildfly -d /opt/wildfly -s /sbin/nologin wildfly
  WILDFLY_VERSION=18.0.1.Final
  wget https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz -P /tmp
  sudo tar xf /tmp/wildfly-$WILDFLY_VERSION.tar.gz -C /opt/
  sudo ln -s /opt/wildfly-$WILDFLY_VERSION /opt/wildfly
  sudo chown -RH wildfly: /opt/wildfly
  sudo mkdir -p /etc/wildfly
  sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
  sudo cp /opt/wildfly/docs/contrib/scripts/systemd/launch.sh /opt/wildfly/bin/
  sudo sh -c 'chmod +x /opt/wildfly/bin/*.sh'
  sudo cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/

  sudo systemctl daemon-reload
  sudo systemctl start wildfly
  sudo systemctl enable wildfly
  sudo ufw allow $wildflyPort/tcp

  echo "Adding wildfly admin user"
  sudo /opt/wildfly/bin/add-user.sh "$wildflyUser" "$wildflyPass"

  redirectHttpToWildfly=$(echo "$redirectHttpToWildfly" | tr '[:upper:]' '[:lower:]')
  
  if [[ ! -z "${redirectHttpToWildfly}" ]] && [[ "${redirectHttpToWildfly}" == "true" ]]; then 
      echo "Adding redirect from port 80 to wildfly port: $wildflyPort"
      sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $wildflyPort
  fi
  
fi

