# Enables google apps authentication on the specified Octopus Server instance
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cOctopusServerGoogleAppsAuthentication.md
# for all available options

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerGoogleAppsAuthentication "Enable Google Apps authentication"
        {
            InstanceName = "OctopusServer"
            Enabled = $true
            ClientID = "5743519123-1232358520259-3634528"
            HostedDomain = "https://octopus.example.com"
        }
    }
}
