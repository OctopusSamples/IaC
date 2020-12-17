[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

$pass = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
$octopusAdminCredential = New-Object System.Management.Automation.PSCredential ("Admin", $pass)
$octopusBuiltInWorkerCredential = New-Object System.Management.Automation.PSCredential ("svcBuiltInWorker", $pass)

$MasterKey = "Nc91+1kfZszMpe7DMne8wg=="
$SecureMasterKey = ConvertTo-SecureString $MasterKey -AsPlainText -Force
$MasterKeyCred = New-Object System.Management.Automation.PSCredential  ("notused", $SecureMasterKey)

return @{
    Ensure = "Present";
    State = "Started";
    Name = "OctopusServer";
    WebListenPrefix = "http://localhost:82";
    SqlDbConnectionString = "Server=(local);Database=Octopus;Trusted_Connection=True;";
    OctopusAdminCredential = $octopusAdminCredential;
    ListenPort = 10935;
    AllowCollectionOfUsageStatistics = $false;
    HomeDirectory = "C:\Octopus";
    AutoLoginEnabled = $true
    LicenseKey = "PExpY2Vuc2UgU2lnbmF0dXJlPSJoUE5sNFJvYWx2T2wveXNUdC9Rak4xcC9PeVVQc0l6b0FJS282bk9VM1kzMUg4OHlqaUI2cDZGeFVDWEV4dEttdWhWV3hVSTR4S3dJcU9vMTMyVE1FUT09Ij4gICA8TGljZW5zZWRUbz5PY3RvVGVzdCBDb21wYW55PC9MaWNlbnNlZFRvPiAgIDxMaWNlbnNlS2V5PjI0NDE0LTQ4ODUyLTE1NDI3LTQxMDgyPC9MaWNlbnNlS2V5PiAgIDxWZXJzaW9uPjIuMDwhLS0gTGljZW5zZSBTY2hlbWEgVmVyc2lvbiAtLT48L1ZlcnNpb24+ICAgPFZhbGlkRnJvbT4yMDE3LTEyLTA4PC9WYWxpZEZyb20+ICAgPE1haW50ZW5hbmNlRXhwaXJlcz4yMDIzLTAxLTAxPC9NYWludGVuYW5jZUV4cGlyZXM+ICAgPFByb2plY3RMaW1pdD5VbmxpbWl0ZWQ8L1Byb2plY3RMaW1pdD4gICA8TWFjaGluZUxpbWl0PjE8L01hY2hpbmVMaW1pdD4gICA8VXNlckxpbWl0PlVubGltaXRlZDwvVXNlckxpbWl0PiA8L0xpY2Vuc2U+"
    LogTaskMetrics=$true;
    LogRequestMetrics=$true;
    OctopusMasterKey = $MasterKeyCred;
    ForceSSL = $true;
    OctopusBuiltInWorkerCredential = $octopusBuiltInWorkerCredential;
}
