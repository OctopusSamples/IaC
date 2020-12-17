# Configures the Tentacle watchdog to watch all Tentacle instances

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cTentacleWatchdog "Enable Tentacle Watchdog"
        {
            InstanceName = "Tentacle"
            Enabled = $true
            Interval = 5 # minutes
            Instances = "*" # all instances
        }
    }
}
