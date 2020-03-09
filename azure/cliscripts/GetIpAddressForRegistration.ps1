Param(    
    [string]$resourceGroupName,    
    [string]$vmName
)

Write-Host "ResourceGroup: $resourceGroupName"
Write-Host "VMName: $vmName"
$ipName = $VmName + "Ip"
Write-Host "ipName: $ipName"

$IPAddress = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Name $ipName
$IPAddress = $IPAddress.IpAddress

Write-Host "Setting the output variable IPAddress to $IPAddress"
Set-OctopusVariable -name "IPAddress" -value $IPAddress
