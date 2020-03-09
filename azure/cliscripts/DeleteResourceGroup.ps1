Param(    
    [string]$resourceGroupName
)
Write-Host "Deleting resourcegroup $resourceGroupName"

Remove-AzureRMResourceGroup -Name $resourceGroup -Force
