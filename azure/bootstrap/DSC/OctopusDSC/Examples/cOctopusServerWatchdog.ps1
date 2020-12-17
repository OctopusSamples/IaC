# Configures the Server watchdog to watch all instances

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerWatchdog "Enable Octopus Server Watchdog"
        {
            InstanceName = "OctopusServer"
            Enabled = $true
            Interval = 5 # minutes
            Instances = "*" # all instances
        }
    }
}
