param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $EnvironmentsCsv,
    $SpaceIdFilter
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

$space = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "spaces/$SpaceIdFilter" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$environmentsToCheckList = @($EnvironmentsCsv -split ",")
$environmentsList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "environments?skip=0&take=1000" -spaceId $space.Id -apiKey $OctopusApiKey -item $null -method "GET"

foreach ($environmentToCheck in $environmentsToCheckList)
{
    $found = $false
    foreach ($environment in $environmentsList.Items)
    {
        Write-Verbose "Checking $($environment.Name) with $environmentToCheck"
        if ($environment.Name.ToLower().Trim() -eq $environmentToCheck.ToLower().Trim())
        {
            Write-Host "Environment $environmentToCheck already exists on space $($space.Name)"
            $found = $true
            break
        }
    }

    if ($found -eq $false)
    {
        $environmentToAdd = @{
            Name = $environmentToCheck.Trim()
        }

        $newEnvironment = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "environments" -spaceId $space.Id -apiKey $OctopusApiKey -item $environmentToAdd -method "POST"
        Write-Host "Added the environment $environmentToCheck with the new id $($newEnvironment.Id)"
    }
}

Write-Host "Finished checking environments for all spaces"