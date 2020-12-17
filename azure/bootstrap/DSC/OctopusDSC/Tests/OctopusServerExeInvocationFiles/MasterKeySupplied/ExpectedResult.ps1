return @(
  "create-instance --console --instance HANode --config $($env:SystemDrive)\Octopus\OctopusServer-HANode.config --home C:\ChezOctopusSecondNode",
  "database --instance HANode --connectionstring Server=(local);Database=Octopus;Trusted_Connection=True; --create --masterKey Nc91+1kfZszMpe7DMne8wg== --grant NT AUTHORITY\SYSTEM",
  "configure --console --instance HANode --upgradeCheck True --upgradeCheckWithStatistics False --webForceSSL False --webListenPrefixes http://localhost:82 --commsListenPort 10935 --hstsEnabled False --hstsMaxAge 3600",
  "service --stop --console --instance HANode",
  "admin --console --instance HANode --username Admin --password S3cur3P4ssphraseHere!",
  "license --console --instance HANode --free",
  "path --console --instance HANode --nugetRepository C:\ChezOctopusSecondNode\Packages --artifacts C:\ChezOctopusSecondNode\Artifacts --taskLogs C:\ChezOctopusSecondNode\TaskLogs",
  "service --console --instance HANode --install --reconfigure --stop",
  "service --start --console --instance HANode"
)
