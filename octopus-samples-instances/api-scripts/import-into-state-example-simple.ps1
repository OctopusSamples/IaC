# Backend Authentication
$backendAccountAccessKey = $OctopusParameters["Project.AWS.Backend.Account.AccessKey"]
$backendAccountSecretKey = $OctopusParameters["Project.AWS.Backend.Account.SecretKey"]

Write-Host "Setting environment variables required by the terraform file for backend authentication"
$env:AWS_ACCESS_KEY_ID = $backendAccountAccessKey
$env:AWS_SECRET_ACCESS_KEY = $backendAccountSecretKey

# Remaining variables for environment variables
$awsAccountAccessKey = $OctopusParameters["SpaceStandard.Aws.Account.AccessKey"]
$awsAccountSecret = $OctopusParameters["SpaceStandard.Aws.Account.Secret"]

$azureApplicationId = $OctopusParameters["SpaceStandard.Azure.Account.ApplicationId"]
$azureSubscriptionId = $OctopusParameters["SpaceStandard.Azure.Account.SubscriptionId"]
$azureTenantId = $OctopusParameters["SpaceStandard.Azure.Account.TenantId"]
$azurePassword = $OctopusParameters["SpaceStandard.Azure.Account.Password"]

$octopusUrl = $OctopusParameters["Samples.Octopus.Url"]
$octopusApiKey = $OctopusParameters["Samples.Octopus.Api.Key"]
$spaceId = $OctopusParameters["Project.Standards.SpaceId"]

Write-Host "Setting environment variables for variables defined in variables.tf file"
$env:TF_VAR_octopus_address = $octopusUrl
$env:TF_VAR_octopus_api_key = $octopusApiKey
$env:TF_VAR_octopus_space_id = $spaceId
$env:TF_VAR_octopus_aws_account_access_key = $awsAccountAccessKey
$env:TF_VAR_octopus_aws_account_access_secret = $awsAccountSecret
$env:TF_VAR_octopus_azure_account_application_id = $azureApplicationId
$env:TF_VAR_octopus_azure_account_subscription_id = $azureSubscriptionId
$env:TF_VAR_octopus_azure_account_tenant_id = $azureTenantId
$env:TF_VAR_octopus_azure_account_password = $azurePassword

# Get the working directory for Terraform
$extractedDirectory = $OctopusParameters["Octopus.Action.Package[IaC].ExtractedPath"]
$terraformDirectory = "$extractedDirectory/octopus-samples-instances/terraform"

Write-Host "Setting the current location to $terraformDirectory because that has all the TF files"
set-location $terraformDirectory

# Initialize Terraform with the same backend parameters as what is being used in Octopus when running Terraform Apply
$backendAwsS3Key = $OctopusParameters["Project.AWS.Backend.Key"]
$backendAwsS3Region = $OctopusParameters["Terraform.Init.S3.Region"]
$backendAwsS3Bucket = $OctopusParameters["Terraform.Init.S3.Bucket"]

terraform init -no-color -backend-config="key=$backendAwsS3Key" -backend-config="region=$backendAwsS3Region" -backend-config="bucket=$backendAwsS3Bucket"

Write-Host "Importing the existing Docker Feed into Terraform State"
$dockerFeedOctopusId = $OctopusParameters["SpaceStandard.Octopus.DockerFeedOctopusId"]
terraform import "octopusdeploy_feed.docker" $dockerFeedOctopusId

Write-Host "Importing the existing GitHub feed into Terraform State"
$githubFeedOctopusId = $OctopusParameters["SpaceStandard.Octopus.GitHubFeedOctopusId"]
terraform import "octopusdeploy_feed.github" $githubFeedOctopusId  
