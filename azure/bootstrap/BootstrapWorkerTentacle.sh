#!/bin/bash
# https://linuxize.com/post/how-to-install-wildfly-on-ubuntu-18-04/

# Set field seperator
IFS="="

# Get the arguments that were passed
for var in "$@"
do
    # Split the var
    read -a argument <<<"$var"
    echo "$var"
    # Assign variables
    case "${argument[0]}" in
      "server")
        serverUrl=${argument[1]}
        ;;
      "thumbprint")
        thumbprint=${argument[1]}
        ;;
      "apikey")
        apiKey=${argument[1]}
        ;;
      "name")
        name=${argument[1]}
        ;;
      "publichostname")
        publicHostName=${argument[1]}
        ;;
      "workerpool")
        workerPoolName=${argument[1]}
        ;;
      "space")
        spaceName=${argument[1]}
        ;;
    esac

done

configFilePath="/etc/octopus/default/tentacle-default.config"
applicationPath="/home/Octopus/Applications/"

sudo apt install --no-install-recommends gnupg curl ca-certificates apt-transport-https -y && \
curl -sSfL https://apt.octopus.com/public.key | sudo apt-key add - && \
sudo sh -c "echo deb https://apt.octopus.com/ stable main > /etc/apt/sources.list.d/octopus.com.list" && \
sudo apt update && sudo apt install tentacle -y

sudo /opt/octopus/tentacle/Tentacle create-instance --config "$configFilePath"
sudo /opt/octopus/tentacle/Tentacle new-certificate --if-blank
sudo /opt/octopus/tentacle/Tentacle configure --port 10933 --noListen False --reset-trust --app "$applicationPath"
sudo /opt/octopus/tentacle/Tentacle configure --trust $thumbprint
echo "Registering the Tentacle $name as a worker with server $serverUrl in $workerPoolName"
sudo /opt/octopus/tentacle/Tentacle register-worker --server "$serverUrl" --apiKey "$apiKey" --name "$name" --space "$spaceName" --publicHostName "$publicHostName" --workerpool "$workerPoolName"

