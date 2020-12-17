# Creates an environment in an Octopus Server instance

# deserialize a password from disk
$password = Get-Content .\ExamplePassword.txt | ConvertTo-SecureString
$creds = New-Object PSCredential "username", $password

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusEnvironment "Create 'Development' Environment"
        {
            Url = "https://octopus.example.com"
            Ensure = 'Present'
            EnvironmentName = 'Development'
            OctopusCredentials = $creds
        }
    }
}
