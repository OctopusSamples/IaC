# Enables okta authentication on the specified Octopus Server instance
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cOctopusServerOktaAuthentication.md
# for all available options

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerOktaAuthentication "Enable Okta authentication"
        {
            InstanceName = "OctopusServer"
            Enabled = $true
            Issuer = "https://dev-258250.oktapreview.com"
            ClientId = "752nx5basdskrsbqansE"
        }
    }
}
