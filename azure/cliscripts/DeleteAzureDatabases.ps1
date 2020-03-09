Param(    
    [string]$resourceGroupName,    
    [string]$databaseServerName,
    [string]$databaseNameTemplate
)

Write-Host "ResourceGroupName: $resourceGroupName"
Write-Host "DatabaseServerName: $databaseServerName"
Write-Host "DatabaseNameTemplate: $databaseNameTemplate"

$databaseNameTemplate = "*-" + $databaseNameTemplate

$azureDatabaseList = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $databaseServerName

foreach ($azureDatabase in $azureDatabaseList)
{
    $databaseName = $azureDatabase.DatabaseName
    Write-Host "Checking to see if $databaseName matches the template $databaseNameTemplate"

    if ($databaseName -like $databaseNameTemplate)
    {    	
    	Write-Highlight "Deleting the database $databaseName because it matches the template"
	Remove-AzureRMSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $databaseServerName -DatabaseName $databaseName		
    }
}
