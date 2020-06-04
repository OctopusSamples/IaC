Param(    
    [string]$octopusServerThumbprint,    
    [string]$instanceName,		
		[string]$chocolateyAppList,
		[string]$dismAppList,
		[string]$octopusServer,
		[string]$octopusApiKey,
		[string]$environmentList,
		[string]$roleList,
		[string]$spaceName = "Default",
		[string]$publicHostName,
		[string]$name,
		[string]$firewallRuleList,
		$rebootComputer = "false"
)

Start-Transcript -path "C:\Bootstrap.txt" -append  

Write-Output "Thumbprint: $octopusServerThumbprint"  
Write-Output "InstanceName: $instanceName"
Write-Output "ChocolateyAppList: $chocolateyAppList"
Write-Output "DismAppList: $dismAppList"
Write-Output "FirewallRuleList: $firewallRuleList"
Write-Output "Reboot computer: $rebootComputer"

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
	& .\tentacle.exe configure --instance "Tentacle" --port $tentacleListenPort --noListen "True" --console | Write-Output
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

	# Declare switches array
	$argumentSwitches = @()
	$argumentSwitches += "register-with"

	# Check for empty environments
	if (![string]::IsNullOrEmpty($environmentList))
	{
		# Split the environment list
		ForEach ($environment in $environmentList.Split(","))
		{
			# Add to environment string
			$argumentSwitches += "--environment=`"$environment`""
		}
	}

	
	# Check for empty roles
	if (![string]::IsNullOrEmpty($roleList))
	{
		# Split the role list
		ForEach ($role in $roleList.Split(","))
		{
			# add to role list
			$argumentSwitches += "--role=`"$role`""
		}
	}

	# Build switches
	$argumentSwitches += "--instance=`"Tentacle`""
	$argumentSwitches += "--server=`"$octopusServerUrl`""
	$argumentSwitches += "--apiKey=`"$apiKey`""
	$argumentSwitches += "--space=`"$spaceName`"" 
	$argumentSwitches += "--server-comms-port=`"10943`""

	if (![string]::IsNullOrEmpty($name))
	{
		$argumentSwitches += "--name=`"$name`""
	}

	if (![string]::IsNullOrEmpty($publicHostName)) 
	{
		$argumentSwitches += "--publicHostName=$publicHostName"
	}

	$argumentSwitches += "--comms-style=`"TentacleActive`""


	& .\Tentacle.exe $argumentSwitches

	# Check for registration failure
	if ($lastExitCode -ne 0) { 	   
		$errorMessage = $error[0].Exception.Message	 
	   throw "Registration failed: $errorMessage" 
	 }	

	& .\Tentacle.exe service --instance "Tentacle" --install --stop --start
		
	Write-Output "Tentacle commands complete"     
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

if ([string]::IsNullOrWhiteSpace($dismAppList) -eq $false){
	Write-Host "DISM Apps Specified, installing chocolatey and applications"	

	$appsToInstall = $dismAppList -split "," | foreach { "$($_.Trim())" }

	foreach ($app in $appsToInstall)
	{
		Write-Host "Installing $app"
		& choco install $app /y /source windowsfeatures | Write-Output
	}
}

if ([string]::IsNullOrWhiteSpace($chocolateyAppList) -eq $false){	
	Write-Host "Chocolatey Apps Specified, installing chocolatey and applications"	
	
	$appsToInstall = $chocolateyAppList -split "," | foreach { "$($_.Trim())" }

	foreach ($app in $appsToInstall)
	{
		# Create arguments array
		$argumentSwitches = @()
		$argumentSwitches += "install"

		# Add the arguments -- this will support things like a specific chocolately version specified
		foreach ($option in $app.Split(" "))
		{
			$argumentSwitches += $option
		}

		# Add the /y for acceptance
		$argumentSwitches += "/y"

		Write-Host "Installing $argumentSwitches"
		& choco $argumentSwitches | Write-Output
	}
}

# Check to see if there was firewall rules supplied
if (![string]::IsNullOrEmpty($firewallRuleList))
{
	$firewallRules = $firewallRuleList -split "," | foreach { "$($_.Trim())" }
	
	# Loop through list
	foreach ($firewallRule in $firewallRules)
	{
		# Get number and description
		$firewallRule = $firewallRule.Split(" ")

		# Make sure there's stuff there
		if ($firewallRule.Count -eq 2)
		{
			$firewallRulePort = $firewallRule[0]
			$firewallRuleName = $firewallRule[1]

			# Ensure both elements are present
			if (![string]::IsNullOrEmpty($firewallRulePort) -and ![string]::IsNullOrEmpty($firewallRuleName))
			{
				Write-Output "Open port $firewallRulePort on Windows Firewall" 
				& netsh.exe firewall add portopening TCP $firewallRulePort $firewallRuleName
				if ($lastExitCode -ne 0) { 
					throw "Installation failed when modifying firewall rules" 
				} 		
			}
		}
	}
}

Write-Output "Bootstrap commands complete"  

# Check to see if a reboot was requested
if ($rebootComputer -eq $true)
{
	Write-Output "Rebooting machine."
	Restart-Computer
}