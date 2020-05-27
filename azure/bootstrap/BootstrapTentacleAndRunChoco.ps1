Param(    
    [string]$octopusServerThumbprint,    
    [string]$instanceName,		
    [string]$chocolateyAppList,
	[string]$dismAppList,
	[string]$octopusServerUrl,
	[string]$apiKey,
	[string]$environmentList,
	[string]$roleList,
	[string]$spaceName = "Default",
	[string]$publicHostName,
	[string]$name
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
    $tentacleListenPort = 10933 
    $tentacleHomeDirectory = "C:\Octopus" 
    $tentacleAppDirectory = "C:\Octopus\Applications" 
    $tentacleConfigFile = "C:\Octopus\Tentacle\Tentacle.config"  
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

    
    Write-Output "Open port $tentacleListenPort on Windows Firewall" 
    & netsh.exe firewall add portopening TCP $tentacleListenPort "Octopus Tentacle" 
    if ($lastExitCode -ne 0) { 
        throw "Installation failed when modifying firewall rules" 
    } 

	Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle" 

	Write-Output "Creating the octopus instance"
	& .\tentacle.exe create-instance --instance "Tentacle" --config $tentacleConfigFile --console | Write-Output
	if ($lastExitCode -ne 0) { 	 
	 $errorMessage = $error[0].Exception.Message	 
	 throw "Installation failed on create-instance: $errorMessage" 
	} 
	
	Write-Output "Configuring the home directory"
	& .\tentacle.exe configure --instance "Tentacle" --home $tentacleHomeDirectory --console | Write-Output
	if ($lastExitCode -ne 0) { 	  
	  $errorMessage = $error[0].Exception.Message	 
	  throw "Installation failed on configure: $errorMessage" 
	} 
	
	Write-Output "Configuring the app directory"
	& .\tentacle.exe configure --instance "Tentacle" --app $tentacleAppDirectory --console | Write-Output
	if ($lastExitCode -ne 0) { 	  
	  $errorMessage = $error[0].Exception.Message	 
	  throw "Installation failed on configure: $errorMessage" 
	} 
	
	Write-Output "Configuring the listening port"
	& .\tentacle.exe configure --instance "Tentacle" --port $tentacleListenPort --console | Write-Output
	if ($lastExitCode -ne 0) { 	  
	  $errorMessage = $error[0].Exception.Message	 
	  throw "Installation failed on configure: $errorMessage" 
	} 
	
	Write-Output "Creating a certificate for the tentacle"
	& .\tentacle.exe new-certificate --instance "Tentacle" --console | Write-Output
	if ($lastExitCode -ne 0) { 	  
	  $errorMessage = $error[0].Exception.Message	 
	  throw "Installation failed on creating new certificate: $errorMessage" 
	} 
	
	Write-Output "Trusting the certificate $octopusServerThumbprint"
	& .\tentacle.exe configure --instance "Tentacle" --trust $octopusServerThumbprint --console | Write-Output
	if ($lastExitCode -ne 0) { 	  
	  $errorMessage = $error[0].Exception.Message	 
	  throw "Installation failed on configure: $errorMessage" 
	} 	                

	Write-Output "Finally, installing the tentacle"
	& .\tentacle.exe service --instance "Tentacle" --install --start --console | Write-Output
	if ($lastExitCode -ne 0) { 	   
	   $errorMessage = $error[0].Exception.Message	 
	  throw "Installation failed on service install: $errorMessage" 
	} 
		
	Write-Output "Tentacle commands complete"
	
	# Check to see if a URL and API Key was supplied
	if (![string]::IsNullOrEmpty($octopusServerUrl) -and ![string]::IsNullOrEmpty($apiKey))
	{
		# Declare local working variables
		$environmentString = [string]::Empty
		$roleString = [string]::Empty
		
		# Check for empty environments
		if (![string]::IsNullOrEmpty($environmentList))
		{
			# Conver to array
			$environmentArray = $environmentList.Split(",")
			
			# Split the environment list
			For ($i = 0; $i -lt $environmentArray.Count; $i++)
			{
				# Add to environment string
				$environmentArray[$i] = "--environment='$($environmentArray[$i])'"
			}

			# Join to single string
			$environmentString = $environmentArray -join " "
		}

		
		# Check for empty roles
		if (![string]::IsNullOrEmpty($roleList))
		{
			# Convert to array
			$roleArray = $roleList.Split(",")

			# Split the role list
			For ($i = 0; $i -lt $roleArray.Count; $i++)
			{
				# add to role list
				$roleArray[$i] = "--role='$($roleArray[$i])'"
			}

			# Join to single string
			$roleString = $roleArray -join " "
		}

		# Register tentacle
		Write-Output "Registering tenacle to $octopusServerUrl with $(if(![string]::IsNullOrEmpty($environmentString)){" environments $environmentString"}) $(if(![string]::IsNullOrEmpty($roleString)){" roles $roleString"})"
		& .\tentacle.exe register-with --instance="Tentacle" --server=$octopusServerUrl $(if (![string]::IsNullOrEmpty($name)){"--name=$name"}) $(if (![string]::IsInterned($publicHostName)) {"--publicHostName=$publicHostName"}) --apiKey=$apiKey --space=$spaceName --tentacle-comms-port="10933" $environmentString $roleString 

		if ($lastExitCode -ne 0) { 	   
			$errorMessage = $error[0].Exception.Message	 
		   throw "Registration failed: $errorMessage" 
		 } 	 
	}
} else {
  Write-Output "Tentacle already exists"
}    

if ([string]::IsNullOrWhiteSpace($chocolateyAppList) -eq $false -or [string]::IsNullOrWhiteSpace($dismAppList) -eq $false)
{
	try{
		choco config get cacheLocation
	}catch{
		Write-Output "Chocolatey not detected, trying to install now"
		iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
}

if ([string]::IsNullOrWhiteSpace($chocolateyAppList) -eq $false){	
	Write-Host "Chocolatey Apps Specified, installing chocolatey and applications"	
	
	$appsToInstall = $chocolateyAppList -split "," | foreach { "$($_.Trim())" }

	foreach ($app in $appsToInstall)
	{
		Write-Host "Installing $app"
		& choco install $app /y | Write-Output
	}
}

if ([string]::IsNullOrWhiteSpace($dismAppList) -eq $false){
	Write-Host "DISM Apps Specified, installing chocolatey and applications"	

	$appsToInstall = $dismAppList -split "," | foreach { "$($_.Trim())" }

	foreach ($app in $appsToInstall)
	{
		Write-Host "Installing $app"
		& choco install $app /y /source windowsfeatures | Write-Output
	}
}

Write-Output "Bootstrap commands complete"  
