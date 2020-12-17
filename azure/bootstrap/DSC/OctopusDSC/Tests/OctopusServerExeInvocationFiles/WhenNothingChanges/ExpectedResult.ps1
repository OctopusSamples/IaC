return @(
  "configure --console --instance OctopusServer --upgradeCheck True --upgradeCheckWithStatistics False --webForceSSL True --webListenPrefixes http://localhost:82 --commsListenPort 10935 --home C:\Octopus --autoLoginEnabled True --hstsEnabled False --hstsMaxAge 3600"
)
