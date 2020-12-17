return @(
    "create-instance --instance Tentacle --config C:\Octopus\Tentacle\Tentacle.config --console",
    "new-certificate --instance Tentacle --console",
    "configure --instance Tentacle --home C:\Octopus --app C:\Applications --console --port 10933",
    "service --install --instance Tentacle --console --reconfigure"
)
