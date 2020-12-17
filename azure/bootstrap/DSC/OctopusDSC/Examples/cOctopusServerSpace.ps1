# Creates an environment in an Octopus Server instance

# deserialize a password from disk
$password = Get-Content .\ExamplePassword.txt | ConvertTo-SecureString
$creds = New-Object PSCredential "username", $password

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServerSpace "Ensure Integration Team Space exists"
        {
            Ensure = "Present"
            Name = "Integration Team"
            Description = "The top secret work of the Integration Team"
            SpaceManagersTeamMembers = @('admin')
            SpaceManagersTeams = @('Everyone')
            Url = "https://octopus.example.com"
            OctopusCredentials = $creds
        }
    }
}
