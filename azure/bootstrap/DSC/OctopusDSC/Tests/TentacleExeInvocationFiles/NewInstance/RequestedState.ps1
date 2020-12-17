[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

$pass = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Admin", $pass)

return @{
    Ensure = "Present";
    State = "Started";
    Name = "Tentacle";
    DisplayName = "My Tentacle";
    OctopusServerUrl = "http://localhost:81";
    ApiKey = "API-1234";
    Environments = @("dev", "prod");
    Roles = "web-server";
    CommunicationMode = "Listen"
    ListenPort = 10935;
    TentacleServiceCredential = $cred
    DefaultApplicationDirectory = "C:\Applications"
    TentacleHomeDirectory = "C:\Octopus"
}
