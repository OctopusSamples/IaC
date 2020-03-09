Param(    
    [string]$octopusServerThumbprint,    
    [string]$instanceName,		
		[string]$chocolateyAppList,
		[string]$dismAppList,
		[string]$octopusServer,
		[string]$octopusApiKey	
)

Start-Transcript -path "C:\Bootstrap.txt" -append  

Write-Output "Thumbprint: $octopusServerThumbprint"  
Write-Output "InstanceName: $instanceName"
Write-Output "ChocolateyAppList: $chocolateyAppList"
Write-Output "DismAppList: $dismAppList"

function Get-FileFromServer 
{ 
	param ( 
	  [string]$url, 
	  [string]$saveAs 
	) 

	Write-Host "Downloading $url to $saveAs" 
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
	$downloader = new-object System.Net.WebClient 
	$downloader.DownloadFile($url, $saveAs) 
} 

$OctoTentacleService = Get-Service "OctopusDeploy Tentacle" -ErrorAction SilentlyContinue

if ($OctoTentacleService -eq $null)
{
    $tentacleDownloadPath = "https://octopus.com/downloads/latest/WindowsX64/OctopusTentacle" 	
	
	$tentaclePath = "C:\Tools\Octopus.Tentacle.msi" 

    Write-Output "Beginning Tentacle installation"     

	Write-Output "Downloading latest Octopus Tentacle MSI..." 

	$tentaclePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(".\Tentacle.msi") 
	if ((test-path $tentaclePath) -ne $true) { 
	  Get-FileFromServer $tentacleDownloadPath $tentaclePath 
	} 

	Write-Output "Installing MSI" 
	$msiExitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i Tentacle.msi /quiet" -Wait -Passthru).ExitCode 
	Write-Output "Tentacle MSI installer returned exit code $msiExitCode" 
	if ($msiExitCode -ne 0) { 
	  throw "Installation aborted" 
	} 	

	Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle" 

	& .\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config"
	& .\Tentacle.exe new-certificate --instance "Tentacle" --if-blank
	& .\Tentacle.exe configure --instance "Tentacle" --reset-trust
	& .\Tentacle.exe configure --instance "Tentacle" --app "C:\Octopus\Applications" --port "10933" --noListen "True"
	& .\Tentacle.exe polling-proxy --instance "Tentacle" --proxyEnable "False" --proxyUsername "" --proxyPassword "" --proxyHost "" --proxyPort ""

	& .\Tentacle.exe register-with --instance "Tentacle" --server $octopusServer --name $instanceName --comms-style "TentacleActive" --server-comms-port "10943" --apiKey $apiKey --space "Trident" --environment "Development" --role "Trident-Web"
	& .\Tentacle.exe service --instance "Tentacle" --install --stop --start
		
	Write-Output "Tentacle commands complete"     
} else {
  Write-Output "Tentacle already exists"
}    

Write-Output "Bootstrap commands complete"  