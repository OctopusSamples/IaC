Param(       
	[string]$octopusServerUrl,
	[string]$apiKey,
	[string]$environmentList,
	[string]$roleList,
	[string]$spaceName = "Default",
    [string]$workerPool,
	[string]$octopusServerThumbprint
)

$ErrorActionPreference = "Stop"
$tentacleListenPort = 10933 

Start-Transcript -path "C:\Bootstrap.txt" -append  

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

# Declare switches array
$registrationArgumentSwitches = @()

if (![string]::IsNullOrEmpty($octopusServerUrl) -and ![string]::IsNullOrEmpty($apiKey))
{
	# Check to see if it's a worker or a target
	if (![string]::IsNullOrWhiteSpace($workerPool))
	{
		$registrationArgumentSwitches += "register-worker"
		$registrationArgumentSwitches += "--workerpool=`"$workerPool`""
	}
	else 
	{
		$registrationArgumentSwitches += "register-with"

		# Check for empty environments
		if (![string]::IsNullOrEmpty($environmentList))
		{
			# Split the environment list
			ForEach ($environment in $environmentList.Split(","))
			{
				# Add to environment string
				$registrationArgumentSwitches += "--environment=`"$environment`""
			}
		}

		
		# Check for empty roles
		if (![string]::IsNullOrEmpty($roleList))
		{
			# Split the role list
			ForEach ($role in $roleList.Split(","))
			{
				# add to role list
				$registrationArgumentSwitches += "--role=`"$role`""
			}
		}
	}
	
	# Build switches
	$registrationArgumentSwitches += "--instance=`"Tentacle`""
	$registrationArgumentSwitches += "--server=`"$octopusServerUrl`""
	$registrationArgumentSwitches += "--apiKey=`"$apiKey`""
	$registrationArgumentSwitches += "--space=`"$spaceName`"" 	
	$registrationArgumentSwitches += "--server-comms-port=`"$tentacleListenPort`""
	$registrationArgumentSwitches += "--console"
	$registrationArgumentSwitches += "--force"
}

$OctoTentacleService = Get-Service "OctopusDeploy Tentacle" -ErrorAction SilentlyContinue

if ($null -eq $OctoTentacleService)
{
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
	(& .\tentacle.exe create-instance --instance "Tentacle" --config $tentacleConfigFile --console) | Write-Output
    Write-Output "Creating a new certificate"
	(& .\tentacle.exe new-certificate --instance "Tentacle" --if-blank --console) | Write-Output
    Write-Output "Resetting the trust"
	(& .\tentacle.exe configure --instance "Tentacle" --reset-trust --console) | Write-Output
	Write-Output "Setting the tentacle to trust the octopus instance"
	(& .\tentacle.exe configure --instance "Tentacle" --trust $octopusServerThumbprint --console) | Write-Output
    Write-Output "Configuring the home directory"
	(& .\tentacle.exe configure --instance "Tentacle" --home $tentacleHomeDirectory --app $tentacleAppDirectory --noListen "False" --console) | Write-Output
	Write-Output "Setting the port"
	(& .\tentacle.exe configure --instance "Tentacle" --port $tentacleListenPort --console) | Write-Output
	Write-Output "Creating the tentacle instance"
    (& .\Tentacle.exe service --instance "Tentacle" --install --start --console) | Write-Output

	if ($registrationArgumentSwitches.Length -gt 0)
	{		
		# Register tentacle
		Write-Output "Registering tenacle to $octopusServerUrl with $registrationArgumentSwitches"		
		(& .\tentacle.exe $registrationArgumentSwitches) | Write-Output
	}
}
elseif ($registrationArgumentSwitches.Length -gt 0)
{
	Write-Output "The tentacle already exists, going to reforce the registration in the event the machine got somehow deleted from Octopus."

	Write-Output "Registering tenacle to $octopusServerUrl with $registrationArgumentSwitches"		
	(& .\tentacle.exe $registrationArgumentSwitches) | Write-Output			
}