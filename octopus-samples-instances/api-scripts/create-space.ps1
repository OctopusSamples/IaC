param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $SpaceName,
    $SpaceManagerTeam,
    $AdminInstanceUrl,
    $AdminInstanceApiKey,
    $AdminEnvironmentName,
    $AdminSpaceName    
)

function Invoke-OctopusApi
{
    param
    (
        $octopusUrl,
        $endPoint,
        $spaceId,
        $apiKey,
        $method,
        $item
    )
    
    if ([string]::IsNullOrWhiteSpace($SpaceId))
    {
        $url = "$OctopusUrl/api/$EndPoint"
    }
    else
    {
        $url = "$OctopusUrl/api/$spaceId/$EndPoint"    
    }  
    
    if ([string]::IsNullOrWhiteSpace($method))
    {
    	$method = "GET"
    }

    try
    {
        if ($null -eq $item)
        {
            Write-Verbose "No data to post or put, calling bog standard invoke-restmethod for $url"
            return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -ContentType 'application/json; charset=utf-8' -TimeoutSec 60
        }

        $body = $item | ConvertTo-Json -Depth 10
        Write-Verbose $body

        Write-Verbose "Invoking $method $url"
        return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -Body $body -ContentType 'application/json; charset=utf-8' -TimeoutSec 60
    }
    catch
    {
        Write-Host "There was an error making a $method call to $url.  All request information (JSON body specifically) are logged as verbose.  Please check that for more information." -ForegroundColor Red

        if ($null -ne $_.Exception.Response)
        {
            if ($_.Exception.Response.StatusCode -eq 401)
            {
                Write-Host "Unauthorized error returned from $url, please verify API key and try again" -ForegroundColor Red
            }
            elseif ($_.ErrorDetails.Message)
            {                
                Write-Host -Message "Error calling $url StatusCode: $($_.Exception.Response) $($_.ErrorDetails.Message)" -ForegroundColor Red
                Write-Host $_.Exception -ForegroundColor Red
            }            
            else 
            {
                Write-Host $_.Exception -ForegroundColor Red
            }
        }
        else
        {
            Write-Host $_.Exception -ForegroundColor Red
        }

        Exit 1
    }    
}

$teamList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "teams?partialName=$([uri]::EscapeDataString($SpaceManagerTeam))&includeSystem=true&skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$teamToInclude = $null

foreach ($team in $teamList.Items)
{
	Write-Verbose "Comparing $($team.Name) with $SpaceManagerTeam"
	if ($team.Name.ToLower().Trim() -eq $SpaceManagerTeam.ToLower().Trim())
    {
    	Write-Verbose "The team names match"
    	$teamToInclude = $team
        break
    }
}

if ($null -eq $teamToInclude)
{
    Write-Host "Unable to find team $SpaceManagerTeam on $octopusUrl.  Exiting." -ForegroundColor Red
    Exit 1
}

$spaceToCreate = @{
    IsDefault = $false
    Name = $SpaceName
    SpaceManagersTeamMembers = @()
    SpaceManagerTeams = @($teamToInclude.Id)
    TaskQueuesStopped = $false
}

$createdSpace = Invoke-OctopusApi -octopusUrl $OctopusUrl -endPoint "spaces" -spaceId $null -apiKey $OctopusApiKey -method "POST" -item $spaceToCreate

Write-Highlight "Created $spaceName with the id of $($createdSpace.Id)"

Write-Host "Queueing a runbook run for $($createdSpace.Name) using the space id $($createdSpace.Id).  The runbook will run on $AdminInstanceUrl for the environment $AdminEnvironmentName in the space $AdminSpaceName"
Write-Host "Running command: octo run-runbook --project ""Standards"" --runbook ""Enforce System Wide Standards"" --environment ""$AdminEnvironmentName"" --variable=""Project.Standards.SpaceId:$($space.Id)"" --server=""$AdminInstanceUrl"" --apiKey=""$AdminInstanceApiKey"" --space=""$AdminSpaceName"" to queue the runbook"
octo run-runbook --project "Standards" --runbook "Enforce System Wide Standards" --environment "$AdminEnvironmentName" --variable="Project.Standards.SpaceId:$($createdSpace.Id)" --server="$AdminInstanceUrl" --apiKey="$AdminInstanceApiKey" --space="$AdminSpaceName"

Write-Highlight "The runbook has been queued to set permissions and add all the base items.  It will take about 2-5 minutes to finish running."