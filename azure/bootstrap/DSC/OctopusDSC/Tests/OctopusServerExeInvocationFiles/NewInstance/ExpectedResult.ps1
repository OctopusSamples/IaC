return @(
  "create-instance --console --instance OctopusServer --config $($env:SystemDrive)\Octopus\OctopusServer-OctopusServer.config --home C:\Octopus",
  "database --instance OctopusServer --connectionstring Server=(local);Database=Octopus;Trusted_Connection=True; --create --grant NT AUTHORITY\SYSTEM",
  "configure --console --instance OctopusServer --upgradeCheck True --upgradeCheckWithStatistics False --webForceSSL False --webListenPrefixes http://localhost:81 --commsListenPort 10935 --hstsEnabled False --hstsMaxAge 3600",
  "service --stop --console --instance OctopusServer",
  "admin --console --instance OctopusServer --username Admin --password S3cur3P4ssphraseHere!",
  "license --console --instance OctopusServer --free",
  "path --console --instance OctopusServer --nugetRepository F:\Packages --artifacts G:\Artifacts --taskLogs E:\TaskLogs",
  "node --console --instance OctopusServer --taskCap 10",
  "service --console --instance OctopusServer --install --reconfigure --stop",
  "service --start --console --instance OctopusServer"
)
