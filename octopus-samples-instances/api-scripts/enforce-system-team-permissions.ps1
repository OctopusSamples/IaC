param 
{
    $OctopusUrl,
    $OctopusApiKey,
    $RolesAllowedCsv,
    $TeamName
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

$rolesAllowedSplit = @($RolesAllowedCsv -split ",")

$roleList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "userroles/all" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$rolesAllowedList = @()

foreach ($role in $roleList)
{
	foreach ($roleName in $rolesAllowedSplit)
    {
    	Write-Verbose "Comparing $($role.Name) with $roleName"
    	if ($role.Name.ToLower().Trim() -eq $roleName.ToLower().Trim())
        {
        	Write-Verbose "The roles match, adding to allowed list"
            $rolesAllowedList += $role            
        }
    }
}

$teamList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "teams?partialName=$([uri]::EscapeDataString($teamName))&includeSystem=true&skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
$teamToUpdate = $null

foreach ($team in $teamList.Items)
{
	Write-Verbose "Comparing $($team.Name) with $teamName"
	if ($team.Name.ToLower().Trim() -eq $teamName.ToLower().Trim())
    {
    	Write-Verbose "The team names match"
    	$teamToUpdate = $team
        break
    }
}

$teamScopedUserRoles = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "teams/$($teamToUpdate.Id)/scopeduserroles?skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"

$spaceIdList = @()
foreach ($userRole in $teamScopedUserRoles.Items)
{
	if ($spaceIdList -notcontains $userRole.SpaceId)
    {
    	Write-Verbose "Adding the space $($userRole.SpaceId) to the space list"
    	$spaceIdList += $userRole.SpaceId
    }
}

$spacesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "spaces?skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"
foreach ($space in $spacesList.Items)
{    	
 	Write-Verbose "Checking to see if $($space.Id) is already in the list"
	if ($spaceIdList -notcontains $space.Id)
    {
    	Write-Verbose "Adding the space $($space.SpaceId) to the space list"
        $spaceIdList += $space.Id
    }
}

foreach ($spaceId in $spaceIdList)
{
	Write-Verbose "Getting a list of all the matching assigned roles for $spaceId for this team"
	$matchingSpaceUserRoleList = @($teamScopedUserRoles.Items | Where-Object {$_.SpaceId -eq $spaceId})
    
	foreach ($roleAllowed in $rolesAllowedList)
    {
    	$found = $false
        foreach ($matchingSpaceUserRole in $matchingSpaceUserRoleList)
        {
        	if ($matchingSpaceUserRole.UserRoleId -eq $roleAllowed.Id)
            {
            	Write-Host "User role $($roleAllowed.Name) has been assigned to $teamName for $spaceId.  Checking if it is scoped to anything."
            	$found = $true
                $update = $false
                
                if ($matchingSpaceUserRole.ProjectIds.Count -gt 0)
                {
                	Write-Host "Project scoping found, removing it."
                	$update = $true
                    $matchingSpaceUserRole.ProjectIds = @()
                }
                
                if ($matchingSpaceUserRole.EnvironmentIds.Count -gt 0)
                {
                	Write-Host "Environment scoping found, removing it."
                	$update = $true
                    $matchingSpaceUserRole.EnvironmentIds = @()
                }
                
                if ($matchingSpaceUserRole.TenantIds.Count -gt 0)
                {
                	Write-Host "Tenant scoping found, removing it."
                	$update = $true
                    $matchingSpaceUserRole.TenantIds = @()
                }
                
                if ($matchingSpaceUserRole.ProjectGroupIds.Count -gt 0)
                {
                	Write-Host "Project Group scoping found, removing it."
                	$update = $true
                    $matchingSpaceUserRole.ProjectGroupIds = @()
                }
                
                if ($update -eq $true)
                {
                	Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "scopeduserroles/$($matchingSpaceUserRole.Id)" -spaceId $null -apiKey $OctopusApiKey -item $matchingSpaceUserRole -method "PUT"
                }
                
                break
            }
        }
        
        if ($found -eq $false)
        {
        	$scopedUserRoleToAdd = @{
            	UserRoleId = $roleAllowed.Id
                TeamId = $teamToUpdate.Id
                ProjectIds = @()
                EnvironmentIds = @()
                TenantIds = @()
                ProjectGroupIds = @()
                SpaceId = $spaceId
            }
            
            Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "scopeduserroles" -spaceId $null -apiKey $OctopusApiKey -item $scopedUserRoleToAdd -method "POST"
        }
    }
    
    Write-Verbose "Now that we've verified all the roles that need to be assigned are there, let's make sure there are no additional roles."
    foreach ($matchingUserRole in $matchingSpaceUserRoleList)
    {
    	Write-Verbose "Making sure $($matchingUserRole.UserRoleId) for $($matchingUserRole.Id) is in the role allowed list."
    	$allowedRole = $false
    	foreach ($roleAllowed in $rolesAllowedList)
        {
        	Write-Verbose "Checking to see $($matchingUserRole.UserRoleId) matches $($roleAllowed.Id)."
        	if ($matchingUserRole.UserRoleId -eq $roleAllowed.Id)
            {
            	Write-Verbose "The roles match, this role is therefore allowed, moving onto the next role."
            	$allowedRole = $true
                break
            }
        }
        
        if ($allowedRole -eq $false)
        {
        	Write-Host "Removing scoped user role $($matchingUserRole.Id) because it is assigned to $($matchingUserRole.UserRoleId)."
        	Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "scopeduserroles/$($matchingUserRole.Id)" -spaceId $null -apiKey $OctopusApiKey -item $null -method "DELETE"
        }
    }
}

Write-Host "Finished verifying permissions for $teamName"