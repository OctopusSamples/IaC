param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $SpaceIdFilter,
    $StepName
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

$documentTypesToSearchFor = "Spaces,Lifecycles,Runbooks,Environments"
$rightNow = Get-Date
$tomorrow = $rightNow.AddDays(1)
$end = "$($tomorrow.Year)-$($tomorrow.Month)-$($tomorrow.Day)"

$startDate = $rightNow.AddDays(-3)
$start = "$($startDate.Year)-$($startDate.Month)-$($startDate.Day)"

Write-Host "Pulling back all the corresponding audit events from the previous two days."
$rawAuditEvents = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "events?eventCategories=Created,Modified&from=$($start)&to=$($end)&documentTypes=$($documentTypesToSearchFor)&spaces=$($SpaceIdFilter)&includeSystem=true&excludeDifference=true&skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$auditEventList = $rawAuditEvents.Items

$spaceCreatedOrModified = $false
$runbooksModifiedOrCreated = $false
$lifecyclesModifiedOrCreated = $false

foreach ($auditEvent in $auditEventList)
{
    foreach ($relatedDocumentId in @($auditEvent.RelatedDocumentIds))
    {
        Write-Host "Looking at $relatedDocumentId for potential changes we need to be worried about."        
        if ($relatedDocumentId -like "Spaces-*")
        {
            Write-Host "Space modification detected."
            $spaceCreatedOrModified = $true
        }
        elseif ($relatedDocumentId -like "Runbooks-*")
        {
            Write-Host "Runbook modification detected."
            $runbooksModifiedOrCreated = $true
        }
        elseif ($relatedDocumentId -like "Lifecycles-*")
        {
            Write-Host "Lifecycle modification detected."
            $lifecyclesModifiedOrCreated = $true
        }
    }
}

Write-Highlight "Setting the output variable 'Octopus.Action[$($stepName)].Output.SpaceModifiedOrCreated' to $spaceCreatedOrModified"
Set-OctopusVariable -Name "SpaceModifiedOrCreated" -Value $spaceCreatedOrModified

Write-Highlight "Setting the output variable 'Octopus.Action[$($stepName)].Output.RunbookModifiedOrCreated' to $runbooksModifiedOrCreated"
Set-OctopusVariable -Name "RunbookModifiedOrCreated" -Value $runbooksModifiedOrCreated

$outputLifeCycleModifiedOrCreated = $false
if ($spaceCreatedOrModified -or $lifecyclesModifiedOrCreated)
{
    $outputLifeCycleModifiedOrCreated = $true
}

Write-Highlight "Setting the output variable 'Octopus.Action[$($stepName)].Output.LifecycleModifiedOrCreated' to $outputLifeCycleModifiedOrCreated"
Set-OctopusVariable -Name "LifecycleModifiedOrCreated" -value $outputLifeCycleModifiedOrCreated