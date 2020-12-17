# Enables Active Directory authentication on the specified Octopus Server instance
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cOctopusServerActiveDirectoryAuthentication.md
# for all available options

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerActiveDirectoryAuthentication "Enable AD authentication"
        {
            InstanceName = "OctopusServer"
            Enabled = $true
            AllowFormsAuthenticationForDomainUsers = $false
            ActiveDirectoryContainer = "CN=Users,DC=GPN,DC=COM"
        }
    }
}
