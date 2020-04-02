Param(
	[string]$OctopusUrl,
	[string]$OctopusApiKey,
	[string]$SpaceId,
	[string]$IPAddress,	
	[string]$VmName,
	[bool]$IsTarget
)
Write-Host "Octopus Url: $OctopusUrl"
Write-Host "Octopus API Key: Sensitive" 
Write-Host "SpaceId: $SpaceId"
Write-Host "Machine IP Address: $IPAddress"
Write-Host "Machine Name: $VmName"
Write-Host "Is Target: $IsTarget"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()

$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("X-Octopus-ApiKey", $OctopusAPIKey)

if ($IsTarget -eq $true)
{
	$existingMachineResultsUrl = "$OctopusUrl/api/$SpaceId/machines?partialName=$vmName&skip=0&take=1000"
}
else
{
	$existingMachineResultsUrl = "$OctopusUrl/api/$SpaceId/workers?partialName=$vmName&skip=0&take=1000"
}
Write-Host "Attempting to find existing machine with similar name at $existingMachineResultsUrl"
$existingMachineResponse = Invoke-RestMethod $existingMachineResultsUrl -Headers $header
Write-Host $existingMachineResponse

$machineFound = $false
foreach ($item in $existingMachineResponse.Items)
{
	if ($item.Name -eq $vmName)
	{
	    	$machineFound = $true
        	break
	}
}

if ($machineFound)
{
	Write-Highlight "Machine already exists, skipping waiting"
    	Exit 0
}

$waitCount = 0
$url = "https://$($IPAddress):10933"
Write-Highlight "Waiting for 10 seconds before trying first hit $url"
Start-Sleep -Seconds 10

while ($waitCount -le 180)
{
	$waitCount += 1
    
    try{
        Write-Highlight "Attempting to hit the server $url"
        $result = Invoke-RestMethod $url -TimeoutSec 10
        Write-Highlight "Found tentacle"
        break
    }
    catch {        
        Start-Sleep -Seconds 5
        Write-Highlight "15 Second Timeout"        
    }
}
