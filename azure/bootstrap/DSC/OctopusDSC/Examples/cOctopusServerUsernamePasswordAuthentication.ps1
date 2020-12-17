# Enables username/password authentication on the specified Octopus Server instance
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cOctopusServerUsernamePasswordAuthentication.md
# for all available options

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerUsernamePasswordAuthentication "Enable Username/Password Auth"
        {
            InstanceName = "OctopusServer"
            Enabled = $true
        }
    }
}
