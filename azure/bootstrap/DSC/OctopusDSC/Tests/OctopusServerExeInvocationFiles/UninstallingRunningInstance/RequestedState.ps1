[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

$pass = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("Admin", $pass)

return @{
  Ensure = "Absent";
  Name = "Octopus"
  State = "Stopped";
  WebListenPrefix = "http://localhost:81";
  SqlDbConnectionString = "Server=(local);Database=Octopus;Trusted_Connection=True;";
  OctopusAdminCredential = $cred;
}
