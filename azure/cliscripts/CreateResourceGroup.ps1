Param(    
    [string]$resourceGroupName,    
    [string]$resourceGroupLocation
)

Write-Highlight "ResourceGroupName: $resourceGroupName"
Write-Highlight "ResourceGroupLocation: $resourceGroupLocation"

Try {
    Get-AzureRmResourceGroup -Name $resourceGroupName    
    $createResourceGroup = $false
} Catch {
    $createResourceGroup = $true
}

if ($createResourceGroup -eq $true){
    New-AzureRmResourceGroup -Name $resourceGroupName -Location "$resourceGroupLocation"    
}
