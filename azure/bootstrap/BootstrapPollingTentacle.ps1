Param(       
	[string]$octopusServerUrl,
	[string]$apiKey,
	[string]$environmentList,
	[string]$roleList,
	[string]$spaceName = "Default",
    [string]$workerPool
)

$ErrorActionPreference = "Stop"

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
    
    Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle" 

	Write-Output "Creating the octopus instance"
	(& .\tentacle.exe create-instance --instance "Tentacle" --config $tentacleConfigFile --console) | Write-Output
    Write-Output "Creating a new certificate"
	(& .\tentacle.exe new-certificate --instance "Tentacle" --if-blank --console) | Write-Output
    Write-Output "Resetting the trust"
	(& .\tentacle.exe configure --instance "Tentacle" --reset-trust --console) | Write-Output
    Write-Output "Configuring the home directory"
	(& .\tentacle.exe configure --instance "Tentacle" --home $tentacleHomeDirectory --app $tentacleAppDirectory --noListen "True" --console) | Write-Output

	if (![string]::IsNullOrEmpty($octopusServerUrl) -and ![string]::IsNullOrEmpty($apiKey))
	{
		# Declare switches array
		$argumentSwitches = @()

		# Check to see if it's a worker or a target
		if (![string]::IsNullOrWhiteSpace($workerPool))
		{
			$argumentSwitches += "register-worker"
			$argumentSwitches += "--workerpool=`"$workerPool`""
		}
		else 
		{
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
		}
		
		# Build switches
		$argumentSwitches += "--instance=`"Tentacle`""
		$argumentSwitches += "--server=`"$octopusServerUrl`""
		$argumentSwitches += "--apiKey=`"$apiKey`""
		$argumentSwitches += "--space=`"$spaceName`"" 
		$argumentSwitches += "--comms-style=`"TentacleActive`"" 
		$argumentSwitches += "--server-comms-port=`"10943`""
		$argumentSwitches += "--console"

		# Register tentacle
		Write-Output "Registering tenacle to $octopusServerUrl with $argumentSwitches"		
		(& .\tentacle.exe $argumentSwitches) | Write-Output
	}

	Write-Output "Creating the tentacle instance"
    (& .\Tentacle.exe service --instance "Tentacle" --install --start --console) | Write-Output
}