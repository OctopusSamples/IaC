# Configures an Octopus Server to send logs to Seq (https://getseq.net)

# deserialize a password from disk
$password = Get-Content .\ExamplePassword.txt | ConvertTo-SecureString
$apiKeyCreds = New-Object PSCredential "ignored", $password

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusSeqLogger "Enable Logging to Seq for Octopus Server"
        {
            InstanceType = "OctopusServer"
            Ensure = 'Present'
            SeqServer = 'https://seq.example.com'
            SeqApiKey = $apiKeyCreds
            Properties = @{ Application = 'Octopus'; 'ApplicationSet' = 'BuildAndDeploy' }
        }
    }
}
