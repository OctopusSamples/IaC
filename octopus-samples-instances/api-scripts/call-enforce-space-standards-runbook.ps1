param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $AdminInstanceUrl,
    $AdminInstanceApiKey,
    $AdminEnvironmentName,
    $AdminSpaceName,
    $OptionalSpaceId
)

# Fix ANSI Color on PWSH Core issues when displaying objects
if ($PSEdition -eq "Core") {
    Write-Verbose "Setting OutputRendering setting to PlainText"
    $PSStyle.OutputRendering = "PlainText"
}

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

$rawSpacesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "spaces?skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$spacesList = $rawSpacesList.Items

if ([string]::IsNullOrWhiteSpace($OptionalSpaceId) -eq $false -and $OptionalSpaceId.ToLower().Trim() -ne "all")
{
    $spacesList = @($spacesList | Where-Object {$_.Id -eq $OptionalSpaceId})
}

# Set environment variables for octopus cli execution
$env:OCTOPUS_URL = $AdminInstanceUrl
$env:OCTOPUS_API_KEY = $AdminInstanceApiKey

Write-Verbose "Setting stderr to progress"
Write-Host "##octopus[stderr-progress]"
foreach ($space in $spacesList)
{
    Write-Host "Queueing a runbook run for $($space.Name) using the space id $($space.Id).  The runbook will run on $AdminInstanceUrl for the environment $AdminEnvironmentName in the space $AdminSpaceName"
    Write-Host "Running command: octopus runbook run --project ""Standards"" --name ""Enforce Space Standards"" --environment ""$AdminEnvironmentName"" --variable=""Project.Standards.SpaceId:$($space.Id)"" --space=""$AdminSpaceName"" to queue the runbook"
    
    & octopus runbook run --project "Standards" --name "Enforce Space Standards" --environment "$AdminEnvironmentName" --variable="Project.Standards.SpaceId:$($space.Id)" --space="$AdminSpaceName" --no-prompt
}
Write-Host "##octopus[stderr-default]"
