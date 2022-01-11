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

# The Octopus Instance information to modify
$octopusUrl = $OctopusParameters["Samples.Octopus.Url"]
$octopusApiKey = $OctopusParameters["Samples.Octopus.Api.Key"]
$spaceId = $OctopusParameters["Project.Standards.SpaceId"]

$feedType = "Docker"
$feedUrl = "https://index.docker.io"

# Get the working directory for Terraform
$extractedDirectory = $OctopusParameters["Octopus.Action.Package[IaC].ExtractedPath"]
$terraformDirectory = "$extractedDirectory/octopus-samples-instances/terraform"

# Backend Authentication
$backendAccountAccessKey = $OctopusParameters["Project.AWS.Backend.Account.AccessKey"]
$backendAccountSecretKey = $OctopusParameters["Project.AWS.Backend.Account.SecretKey"]

Write-Host "The backend account access key is $backendAccountAccessKey"

# Remaining variables for environment variables
$awsAccountAccessKey = $OctopusParameters["SpaceStandard.Aws.Account.AccessKey"]
$awsAccountSecret = $OctopusParameters["SpaceStandard.Aws.Account.Secret"]

$azureApplicationId = $OctopusParameters["SpaceStandard.Azure.Account.ApplicationId"]
$azureSubscriptionId = $OctopusParameters["SpaceStandard.Azure.Account.SubscriptionId"]
$azureTenantId = $OctopusParameters["SpaceStandard.Azure.Account.TenantId"]
$azurePassword = $OctopusParameters["SpaceStandard.Azure.Account.Password"]

Write-Host "Setting environment variables required by the terraform file"
$env:AWS_ACCESS_KEY_ID = $backendAccountAccessKey
$env:AWS_SECRET_ACCESS_KEY = $backendAccountSecretKey
$env:TF_VAR_octopus_address = $octopusUrl
$env:TF_VAR_octopus_api_key = $octopusApiKey
$env:TF_VAR_octopus_space_id = $spaceId
$env:TF_VAR_octopus_aws_account_access_key = $awsAccountAccessKey
$env:TF_VAR_octopus_aws_account_access_secret = $awsAccountSecret
$env:TF_VAR_octopus_azure_account_application_id = $azureApplicationId
$env:TF_VAR_octopus_azure_account_subscription_id = $azureSubscriptionId
$env:TF_VAR_octopus_azure_account_tenant_id = $azureTenantId
$env:TF_VAR_octopus_azure_account_password = $azurePassword

Write-Host "Setting the current location to $terraformDirectory"
set-location $terraformDirectory

terraform init -no-color

Write-Host "Pulling in the current state"
$currentStateAsJson = terraform show -json
$currentState = $currentStateAsJson | ConvertFrom-Json -depth 10

$foundItem = $false
$stateNameToFind = "docker"
$stateTypeToFind = "octopusdeploy_feed"
$terraformId = "$stateTypeToFind.$stateNameToFind"

foreach ($item in $currentState.Values.root_module.resources)
{
	Write-Host "Comparing $($item.Name) with $stateNameToFind and $($item.type) with $stateTypeToFind"
	if ($item.name.ToLower().Trim() -eq $stateNameToFind.ToLower().Trim() -and $item.type.ToLower().Trim() -eq $stateTypeToFind)
    {
    	Write-Host "The item already exists in the state"
        $foundItem = $true
        break
    }
}

if ($foundItem -eq $true)
{
	Write-Host "The item already exists in the state file, no need to continue.  Exiting."
    exit 0
}

Write-Host "The external feed was not found in the state file.  Checking to see if that feed exists currently."
$rawExternalFeedsList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "feeds?feedType=Nuget,Docker,Maven,GitHub,Helm,AwsElasticContainerRegistry&skip=0&take=1000" -spaceId $spaceId -apiKey $OctopusApiKey -item $null -method "GET"
$externalFeedList = $rawExternalFeedsList.Items

$foundFeed = $false
foreach ($feed in $externalFeedList)
{
	Write-Host "Verifying the $($feed.FeedType) matches $feedType, $($feed.FeedUri) matches $feedUrl and that the $($feed.Username) is null or empty"
	if ($feed.FeedType -eq $feedType -and $feed.FeedUri -eq $feedUrl -and [string]::IsNullOrWhiteSpace($feed.Username))
    {
    	Write-Host "The feed in question currently exists already.  Going to import it into state."
        Write-host "Terraform import ""$terraformId"" $($feed.Id)"
        terraform import $terraformId $($feed.Id)
        $foundFeed = $true
        break
    }
}

if ($foundFeed)
{
	Write-Host "Finished importing the existing feed into Terraform"
}
else
{
	Write-Host "The feed you want to import does not exist, the next time the apply command runs it will create a new feed for you."
}

