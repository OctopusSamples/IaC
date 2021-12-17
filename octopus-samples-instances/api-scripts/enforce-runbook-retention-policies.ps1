param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $RunbookMaxRetentionRunPerEnvironment
)

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces/all" -Headers $header 
Write-Output "Space Count: $($spaces.Length)"

foreach ($space in $spaces) {
    Write-Verbose "Working on space $($space.Name)"

	try {
    	$projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header     
    } 
    catch {
        Write-Warning "$($_.Exception.ToString())"
        continue;
    }
    Write-Output "Project Count: $($projects.Length)"

    foreach ($project in $projects) {
        Write-Verbose "Working on project $($project.Name)"
        
        $projectRunbooks = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/runbooks" -Headers $header                 
        $runbooks = $projectRunbooks.Items
        Write-Output "Runbook Count: $($runbooks.Length)"
        
        foreach ($runbook in $runbooks) {
            Write-Verbose "Working on runbook $($runbook.Name)"
            $currentRetentionQuantityToKeep = $runbook.RunRetentionPolicy.QuantityToKeep
            
            if ($currentRetentionQuantityToKeep -gt $runbookMaxRetentionRunPerEnvironment) {
                Write-Output "Runbook '$($runbook.Name)' ($($runbook.Id)) has a retention run policy to keep of: $($currentRetentionQuantityToKeep) which is greater than $($runbookMaxRetentionRunPerEnvironment)"
                $runbook.RunRetentionPolicy.QuantityToKeep = $runbookMaxRetentionRunPerEnvironment
                Write-Output "Updating runbook run quantity to keep for '$($runbook.Name)' ($($runbook.Id)) to $runbookMaxRetentionRunPerEnvironment"

                $runbookResponse = Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/runbooks/$($runbook.Id)" -Body ($runbook | ConvertTo-Json -Depth 10) -Headers $header
                if ($runbookResponse.RunRetentionPolicy.QuantityToKeep -ne $runbookMaxRetentionRunPerEnvironment) {
                    throw "Update for '$($runbook.Name)' ($($runbook.Id)) doesnt look like it worked. QtyToKeep is: $($runbookResponse.RunRetentionPolicy.QuantityToKeep)"
                }
            }
        }
    }
}
