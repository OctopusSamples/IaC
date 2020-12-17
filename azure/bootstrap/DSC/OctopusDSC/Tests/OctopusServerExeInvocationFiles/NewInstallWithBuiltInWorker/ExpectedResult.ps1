return @(
  "create-instance --console --instance OctopusServer --config $($env:SystemDrive)\Octopus\OctopusServer-OctopusServer.config --home C:\Octopus",
  "database --instance OctopusServer --connectionstring Server=(local);Database=Octopus;Trusted_Connection=True; --create --grant NT AUTHORITY\SYSTEM",
  "configure --console --instance OctopusServer --upgradeCheck True --upgradeCheckWithStatistics False --webForceSSL False --webListenPrefixes http://localhost:82 --commsListenPort 10935 --autoLoginEnabled False --hstsEnabled False --hstsMaxAge 3600",
  "service --stop --console --instance OctopusServer",
  "admin --console --instance OctopusServer --username Admin --password S3cur3P4ssphraseHere!",
  "license --console --instance OctopusServer --free",
  "path --console --instance OctopusServer --nugetRepository C:\Octopus\Packages --artifacts C:\Octopus\Artifacts --taskLogs C:\Octopus\TaskLogs",
  "service --console --instance OctopusServer --install --reconfigure --stop",
  "builtin-worker --instance OctopusServer --username runasuser --password S4cretPassword!",
  "service --start --console --instance OctopusServer"
)
