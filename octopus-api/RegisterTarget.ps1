Param(
	[string]$OctopusUrl,
	[string]$OctopusApiKey,
	[string]$SpaceId,
	[string]$IPAddress,	
	[string]$VmName,
	[string]$MachinePolicyId,
	[string]$EnvironmentId,
	[string]$Roles,
	[string]$Tenants,
	[string]$TenantTags,
)

Write-Host "Octopus Url: $OctopusUrl"
Write-Host "Octopus API Key: Sensitive" 
Write-Host "SpaceId: $SpaceId"
Write-Host "Machine IP Address: $IPAddress"
Write-Host "Machine Name: $VmName"
Write-Host "Machine Policy Id: $MachinePolicyId"
Write-Host "Environment Id: $EnvironmentId"
Write-Host "Roles: $Roles"
Write-Host "Tenants: $Tenants"
Write-Host "Tenant Tags: $TenantTags"

$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("X-Octopus-ApiKey", $OctopusAPIKey)

$existingMachineResultsUrl = "$OctopusUrl/api/$SpaceId/machines?partialName=$vmName&skip=0&take=1000"
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
	Write-Highlight "Machine already exists, skipping registration"
    	Exit 0
}

$discoverUrl = "$OctopusUrl/api/$SpaceId/machines/discover?host=$IpAddress&port=10933&type=TentaclePassive"
Write-Host "Discovering the machine $discoverUrl"
$discoverResponse = Invoke-RestMethod $discoverUrl -Headers $header 
Write-Host "ProjectResponse: $discoverResponse"

$machineThumbprint = $discoverResponse.EndPoint.Thumbprint
Write-Host "Thumbprint = $machineThumbprint"

$roleList = $Roles -split ","
$tenantList = $Tenants -split ","
$tenantTagList = $TenantTags -split ","

$TenantedDeploymentParticipation = "Untenanted"
if ([string]::IsNullOrWhiteSpace($Tenants) -eq $false -or [string]::IsNullOrWhiteSpace($TenantTags) -eq $false)
{
	$TenantedDeploymentParticipation = "Tenanted"
}

$rawRequest = @{
	Id = $null;
	MachinePolicyId = $MachinePolicyId;
	Name = $VmName;
	IsDisabled = $false;
	HealthStatus = "Unknown";
	HasLatestCalamari = $true;
	StatusSummary = $null;
	IsInProcess = $true;
	Endpoint = @{
    		Id = $null;
		CommunicationStyle = "TentaclePassive";
		Links = $null;
		Uri = "https://$IpAddress`:10933";
		Thumbprint = "$machineThumbprint";
		ProxyId = $null
	};
	Links = $null;	
	Roles = $roleList;
	EnvironmentIds = @("$Environment");
	TenantIds = $tenantList;
	TenantTags = $tenantTagList;
	TenantedDeploymentParticipation = $TenantedDeploymentParticipation
}

$jsonRequest = $rawRequest | ConvertTo-Json

Write-Host "Sending in the request $jsonRequest"

$machineUrl = "$OctopusUrl/api/$SpaceId/machines"
Write-Host "Creating the machine"
$machineResponse = Invoke-RestMethod $machineUrl -Headers $header -Method POST -Body $jsonRequest

Write-Host "Create machine's response: $machineResponse"
