
# Set working variables
$spaceName = "#{Octopus.Action[Get Samples Spaces].Output.InitialSpaceName}"
$workerPool = "#{Octopus.Action[Get Samples Spaces].Output.WindowsWorkerPoolName}"
$machinePolicyName = "Default Machine Policy"
$serverCommsPort = "10943"
$serverUrl = "#{Samples.Octopus.Url}"
$apiKey = "#{Samples.Octopus.Api.Key}"

# Install chocolaty
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

$OctopusName = $null
try
{
    # This is for AWS
    $OctopusName = (Invoke-RestMethod http://169.254.169.254/latest/meta-data/hostname)
}
catch
{
    # This is for Azure
    if ($_.Exception.Response.StatusCode.value__ -eq 404)
    {
        $OctopusName = ((Invoke-RestMethod "http://169.254.169.254/metadata/instance?api-version=2021-02-01" -Headers @{"MetaData" = "true"}).compute.name)
    }
}

# Use chocolaty to install tentacle
choco install octopusdeploy.tentacle -y

# Configure tentacle
& "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" create-instance --config "c:\octopus\home"
& "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" new-certificate --if-blank
& "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" configure --noListen True --reset-trust --app "c:\octopus\applications"
Write-Host "Running register worker..."
& "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" register-worker --server "$serverUrl" --apiKey "$apiKey"  --comms-style "TentacleActive" --server-comms-port "$serverCommsPort" --workerPool "$workerPool" --policy "$machinePolicyName" --space "$spaceName" --name $OctopusName
Write-Host "Finished register worker..."
& "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" service --install
& "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" service --start

# Install .net 6
choco install dotnet-6.0-sdk -y

# Install PowerShell Core
choco install powershell-core -y

# Install JRE
choco install javaruntime -y

# Install docker engine
#Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
#.\install-docker-ce.ps1
Install-PackageProvider -Name Nuget -Force
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
Restart-Computer -Force