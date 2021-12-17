param 
(
    $OctopusUrl,
    $OctopusApiKey,
    $CommunityStepTemplatesCsv
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

$communityActionTemplatesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "communityactiontemplates?skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$spacesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "spaces?skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$expectedCommunityStepTemplatesList = @($CommunityStepTemplatesCsv -split ",")

foreach ($space in $spacesList.Items)
{
    Write-Verbose "Checking $($space.Name) for the expected pre-installed community step templates"
    
    foreach ($expectedCommunityStepTemplate in $expectedCommunityStepTemplatesList)
    {
        $installStepTemplate = $true
        $stepTemplatesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "actiontemplates?skip=0&take=1000&partialName=$([uri]::EscapeDataString($expectedCommunityStepTemplate.Name))" -spaceId $space.Id -apiKey $OctopusApiKey -item $null -method "GET"

        foreach ($stepTemplate in $stepTemplatesList.Items)
        {
            if ($null -eq $stepTemplate.CommunityActionTemplateId)
            {
                Write-Host "The step template $($stepTemplate.Name) is not a community step template, moving on."
                continue
            }

            if ($stepTemplate.Name.ToLower().Trim() -eq $expectedCommunityStepTemplate.ToLower().Trim())
            {
                Write-Host "The step template $($stepTemplate.Name) matches $expectedCommunityStepTemplate.  No need to install the step template."

                $communityActionTemplate = $communityActionTemplatesList.Items | Where-Object {$_.Id -eq $stepTemplate.CommunityActionTemplateId}                

                if ($null -eq $communityActionTemplate)
                {
                    Write-Host "Unable to find the community step template in the library, skipping the version check."
                    $installStepTemplate = $false
                    break
                }

                if ($communityActionTemplate.Version -eq $stepTemplate.Version)
                {
                    Write-Host "The step template $($stepTemplate.Name) is on version $($stepTemplate.Version) while the matching community template is on version $($communityActionTemplate.Version).  The versions match.  Leaving the step template alone."
                    $installStepTemplate = $false
                }
                else
                {
                    Write-Host "The step template $($stepTemplate.Name) is on version $($stepTemplate.Version) while the matching community template is on version $($communityActionTemplate.Version).  Updating the step template."

                    $actionTemplate = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "communityactiontemplates/$($communityActionTemplateToInstall.Id)/installation/$($space.Id)" -spaceId $null -apiKey $OctopusApiKey -item $null -method "PUT"
                    Write-Host "Succesfully updated the step template.  The version is now $($actionTemplate.Version)"
                }
                
                break
            }
        }

        if ($installStepTemplate -eq $true)
        {
            $communityActionTemplateToInstall = $null
            foreach ($communityStepTemplate in $communityActionTemplatesList.Items)
            {
                if ($communityStepTemplate.Name.ToLower().Trim() -eq $expectedCommunityStepTemplate.ToLower().Trim())
                {
                    $communityActionTemplateToInstall = $communityStepTemplate
                    break
                }
            }

            if ($null -eq $communityActionTemplateToInstall)
            {
                Write-Host -Message "Unable to find $expectedCommunityStepTemplate.  Please either re-sync the community library or check the names.  Exiting." -ForegroundColor Red
                exit 1
            }

            Write-Host "Installing the step template $expectedCommunityStepTemplate to $($space.Name)."
            $actionTemplate = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "communityactiontemplates/$($communityActionTemplateToInstall.Id)/installation/$($space.Id)" -spaceId $null -apiKey $OctopusApiKey -item $null -method "POST"
            Write-Host "Succesfully installed the step template.  The Id of the new action template is $($actionTemplate.Id)"
        }
    }
}

Write-Host "Finished verifying the community step templates have all been installed."