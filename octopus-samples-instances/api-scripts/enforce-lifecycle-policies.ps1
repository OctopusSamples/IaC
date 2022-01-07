param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $MaxReleaseRetentionDaysAllowed,
    $UnitToUse,
    $SpaceIdFilter
)

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Get spaces
$space = Invoke-RestMethod -Uri "$octopusURL/api/spaces/$SpaceIdFilter" -Headers $header 

Write-Output "Working on space $($space.Name)"

$lifecycleList = Invoke-RestMethod -Uri "$octopusUrl/api/$($space.Id)/lifecycles/all" -headers $header
foreach ($lifecycle in $lifecycleList)
{
    Write-Output "		Checking lifecycle $($lifecycle.Name)"
    $changeLifecycle = $false
    if ($lifecycle.ReleaseRetentionPolicy.QuantityToKeep -gt $maxReleaseRetentionDaysAllowed -or $lifecycle.ReleaseRetentionPolicy.Unit -ne $unitToUse)
    {
        Write-Host "			Release retention policy is set to $($lifecycle.ReleaseRetentionPolicy.QuantityToKeep) $($lifecycle.ReleaseRetentionPolicy.Unit), updating to $maxReleaseRetentionDaysAllowed $unitToUse"
        $changeLifecycle = $true
        $lifeCycle.ReleaseRetentionPolicy.QuantityToKeep = $maxReleaseRetentionDaysAllowed
        $lifeCycle.ReleaseRetentionPolicy.Unit = $unitToUse
        $lifeCycle.ReleaseRetentionPolicy.ShouldKeepForever = $false
    }
    
    if ($lifecycle.TentacleRetentionPolicy.QuantityToKeep -gt $maxReleaseRetentionDaysAllowed -or $lifecycle.TentacleRetentionPolicy.Unit -ne $unitToUse)
    {
        Write-Host "			Tentacle retention policy is set to $($lifecycle.TentacleRetentionPolicy.QuantityToKeep) $($lifecycle.TentacleRetentionPolicy.Unit), updating to $maxReleaseRetentionDaysAllowed $unitToUse"
        $changeLifecycle = $true
        $lifeCycle.TentacleRetentionPolicy.QuantityToKeep = $maxReleaseRetentionDaysAllowed
        $lifeCycle.TentacleRetentionPolicy.Unit = $unitToUse
        $lifeCycle.TentacleRetentionPolicy.ShouldKeepForever = $false            
    }
    
    foreach ($phase in $lifecycle.Phases)
    {
        if ($null -ne $phase.ReleaseRetentionPolicy -and ($phase.ReleaseRetentionPolicy.QuantityToKeep -gt $maxReleaseRetentionDaysAllowed -or $phase.ReleaseRetentionPolicy.Unit -ne $unitToUse))
        {
            Write-Host "			Release retention policy for $($phase.Name) is set to $($phase.ReleaseRetentionPolicy.QuantityToKeep) $($phase.ReleaseRetentionPolicy.Unit), updating to $maxReleaseRetentionDaysAllowed $unitToUse"
            $changeLifecycle = $true
            $phase.ReleaseRetentionPolicy.QuantityToKeep = $maxReleaseRetentionDaysAllowed
            $phase.ReleaseRetentionPolicy.Unit = $unitToUse
            $phase.ReleaseRetentionPolicy.ShouldKeepForever = $false
        }

        if ($null -ne $phease.TentacleRetentionPolicy -and ($phase.TentacleRetentionPolicy.QuantityToKeep -gt $maxReleaseRetentionDaysAllowed -or $phase.TentacleRetentionPolicy.Unit -ne $unitToUse))
        {
            Write-Host "			Tentacle retention policy for $($phase.Name) is set to $($phase.TentacleRetentionPolicy.QuantityToKeep) $($phase.TentacleRetentionPolicy.Unit), updating to $maxReleaseRetentionDaysAllowed $unitToUse"
            $changeLifecycle = $true
            $phase.TentacleRetentionPolicy.QuantityToKeep = $maxReleaseRetentionDaysAllowed
            $phase.TentacleRetentionPolicy.Unit = $unitToUse
            $phase.TentacleRetentionPolicy.ShouldKeepForever = $false
        }
    }
    
    if ($changeLifecycle -eq $true)
    {
        Write-Verbose "				Invoking a PUT on $octopusURL/api/$($space.Id)/lifecycles/$($lifecycle.Id)"
        Write-Verbose "				$($lifecycle | ConvertTo-Json -Depth 10)"
        $lifecycleResponse = Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/lifecycles/$($lifecycle.Id)" -Body ($lifecycle | ConvertTo-Json -Depth 10) -Headers $header
    }
}	

Write-Hosted "Finished checking lifecycle policies for $($space.Name)"