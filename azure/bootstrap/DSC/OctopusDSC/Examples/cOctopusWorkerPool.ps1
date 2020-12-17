# Creates a Worker Pool in an Octopus Server instance

# deserialize a password from disk
$password = Get-Content .\ExamplePassword.txt | ConvertTo-SecureString
$creds = New-Object PSCredential "username", $password

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusWorkerPool "Create 'Development' Environment"
        {
            Url = "https://octopus.example.com"
            Ensure = 'Present'
            WorkerPoolName = 'My Ops Worker Pool'
            WorkerPoolDescription = "A worker pool for operational tasks"
            SpaceID = "spaces-1"
            OctopusCredentials = $creds
        }
    }
}
