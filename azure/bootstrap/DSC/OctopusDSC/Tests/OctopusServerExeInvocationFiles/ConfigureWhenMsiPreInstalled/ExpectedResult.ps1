return @(
  "create-instance --console --instance OctopusServer --config $($env:SystemDrive)\Octopus\OctopusServer-OctopusServer.config --home C:\Octopus",
  "database --instance OctopusServer --connectionstring Server=(local);Database=Octopus;Trusted_Connection=True; --create --grant NT AUTHORITY\SYSTEM",
  "configure --console --instance OctopusServer --upgradeCheck True --upgradeCheckWithStatistics False --webForceSSL False --webListenPrefixes http://localhost:82 --commsListenPort 10935 --autoLoginEnabled True --hstsEnabled False --hstsMaxAge 3600",
  "service --console --instance OctopusServer --stop",
  "admin --console --instance OctopusServer --username Admin --password S3cur3P4ssphraseHere!",
  "license --console --instance OctopusServer --free",
  "service --console --instance OctopusServer --install --reconfigure --stop",
  "service --start --console --instance OctopusServer"
)
