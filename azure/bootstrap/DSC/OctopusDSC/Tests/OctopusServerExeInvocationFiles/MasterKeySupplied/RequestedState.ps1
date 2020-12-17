[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

$MasterKey = "Nc91+1kfZszMpe7DMne8wg=="
$SecureMasterKey = ConvertTo-SecureString $MasterKey -AsPlainText -Force
$MasterKeyCred = New-Object System.Management.Automation.PSCredential  ("notused", $SecureMasterKey)

$pass = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Admin", $pass)

return @{
    Ensure = "Present";
    State = "Started";
    Name = "HANode";
    WebListenPrefix = "http://localhost:82";
    SqlDbConnectionString = "Server=(local);Database=Octopus;Trusted_Connection=True;";
    OctopusMasterKey = $MasterKeyCred;
    OctopusAdminCredential = $cred;
    ListenPort = 10935;
    AllowCollectionOfUsageStatistics = $false;
    HomeDirectory = "C:\ChezOctopusSecondNode";
}
