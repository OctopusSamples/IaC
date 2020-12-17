# Enables AzureAD authentication on the specified Octopus Server instance
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cOctopusServerAzureADAuthentication.md
# for all available options

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerAzureADAuthentication "Enable AzureAD authentication"
        {
            InstanceName = "OctopusServer"
            Enabled = $true
            Issuer = "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
            ClientId = "0272262a-b31d-4acf-8891-56e96d302018"
        }
    }
}
