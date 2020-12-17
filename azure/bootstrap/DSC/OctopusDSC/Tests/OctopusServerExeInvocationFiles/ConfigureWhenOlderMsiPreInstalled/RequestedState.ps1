[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

$pass = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Admin", $pass)

return @{
    Ensure = "Present";
    State = "Started";
    Name = "OctopusServer";
    WebListenPrefix = "http://localhost:82";
    SqlDbConnectionString = "Server=(local);Database=Octopus;Trusted_Connection=True;";
    OctopusAdminCredential = $cred;
    ListenPort = 10935;
    AllowCollectionOfUsageStatistics = $false;
    HomeDirectory = "C:\Octopus";
    AutoLoginEnabled = $true
    DownloadUrl = "https://octopus-testing.s3.amazonaws.com/server/Octopus.2018.2.8-x64.msi"
}
