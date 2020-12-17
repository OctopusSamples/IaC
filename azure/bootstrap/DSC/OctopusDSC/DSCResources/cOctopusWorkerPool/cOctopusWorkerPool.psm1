# Workers and Worker Pools appeared in 2018.7.0
# Scoping to Spaces in 2019.1.0. TODO: version checking!

# dot-source the helper file (cannot load as a module due to scope considerations)
. (Join-Path -Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -ChildPath 'OctopusDSCHelpers.ps1')

function Get-TargetResource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [OutputType([HashTable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkerPoolName,
        [string]$WorkerPoolDescription,
        [string]$SpaceId,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )
    $workerpool = Get-WorkerPool -Url $Url `
        -WorkerPoolName $WorkerPoolName `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey
    $existingEnsure = 'Present'
    if ($null -eq $workerpool) {
        $existingEnsure = 'Absent'
    }

    $result = @{
        Url                   = $Url;
        Ensure                = $existingEnsure
        WorkerPoolName        = $WorkerPoolName
        WorkerPoolDescription = $WorkerPoolDescription
        SpaceId               = $SpaceId
        OctopusCredentials    = $OctopusCredentials
        OctopusApiKey         = $OctopusApiKey
    }

    return $result
}

function Set-TargetResource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkerPoolName,
        [string]$WorkerPoolDescription,
        [string]$SpaceId,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    $currentResource = Get-TargetResource -Url $Url `
        -Ensure $Ensure `
        -WorkerPoolName $WorkerPoolName `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    if ($Ensure -eq "Absent" -and $currentResource.Ensure -eq "Present") {
        Remove-WorkerPool -Url $Url `
            -WorkerPoolName $WorkerPoolName `
            -OctopusCredentials $OctopusCredentials `
            -OctopusApiKey $OctopusApiKey
    }
    elseif ($Ensure -eq "Present" -and $currentResource.Ensure -eq "Absent") {
        New-WorkerPool -Url $Url `
            -WorkerPoolName $WorkerPoolName `
            -WorkerPoolDescription $WorkerPoolDescription `
            -SpaceId $SpaceId `
            -OctopusCredentials $OctopusCredentials `
            -OctopusApiKey $OctopusApiKey

    }
}

function Test-TargetResource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkerPoolName,
        [string]$WorkerPoolDescription,
        [string]$SpaceId,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )
    $currentResource = (Get-TargetResource -Url $Url `
            -Ensure $Ensure `
            -WorkerPoolName $WorkerPoolName `
            -WorkerPoolDescription $WorkerPoolDescription `
            -SpaceID $SpaceId `
            -OctopusCredentials $OctopusCredentials `
            -OctopusApiKey $OctopusApiKey)

    $params = Get-ODSCParameter $MyInvocation.MyCommand.Parameters

    $currentConfigurationMatchesRequestedConfiguration = $true
    foreach ($key in $currentResource.Keys) {
        $currentValue = $currentResource.Item($key)
        $requestedValue = $params.Item($key)

        if ($currentValue -ne $requestedValue) {
            Write-Verbose "(FOUND MISMATCH) Configuration parameter '$key' with value '$currentValue' mismatched the specified value '$requestedValue'"
            $currentConfigurationMatchesRequestedConfiguration = $false
        }
        else {
            Write-Verbose "Configuration parameter '$key' matches the requested value '$requestedValue'"
        }
    }

    return $currentConfigurationMatchesRequestedConfiguration
}

function Remove-WorkerPool {
    param (
        [string]$Url,
        [string]$WorkerPoolName,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey


    $workerpool = $repository.WorkerPools.FindByName($WorkerPoolName)
    $repository.WorkerPools.Delete($workerpool)
}

function New-WorkerPool {
    param (
        [string]$Url,
        [string]$WorkerPoolName,
        [string]$WorkerPoolDescription,
        [string]$SpaceId,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )
    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    $workerpool = New-Object Octopus.Client.Model.WorkerPoolResource
    $workerpool.Name = $WorkerPoolName
    $workerpool.Description = $WorkerPoolDescription
    $workerpool.SpaceId = $SpaceId
    $repository.WorkerPools.Create($workerpool) | Out-Null
}

function Get-WorkerPool {
    param (
        [string]$Url,
        [string]$WorkerPoolName,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    $workerpool = $repository.WorkerPools.FindByName($WorkerPoolName)
    return $workerpool
}


function Get-OctopusClientRepository
{
  param (
    [string]$Url,
    [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
    [PSCredential]$OctopusApiKey = [PSCredential]::Empty
  )

  if ((($null -eq $OctopusCredentials) -or ($OctopusCredentials -eq [PSCredential]::Empty)) -and (($null -eq $OctopusApiKey) -or ($OctopusApiKey -eq [PSCredential]::Empty))) {
    throw "Please provide either 'OctopusCredentials' or 'OctopusApiKey'."
  }
  if ((($null -ne $OctopusCredentials) -and ($OctopusCredentials -ne [PSCredential]::Empty)) -and (($null -ne $OctopusApiKey) -and ($OctopusApiKey -ne [PSCredential]::Empty))) {
    throw "Please provide either 'OctopusCredentials' or 'OctopusApiKey', not both."
  }

  $tempFolder = [System.IO.Path]::GetTempPath()
  $shadowCopyFolder = Join-Path $tempFolder ([Guid]::NewGuid())
  New-Item -type Directory $shadowCopyFolder | Out-Null

  $filename = "${env:ProgramFiles}\Octopus Deploy\Octopus\Newtonsoft.Json.dll"
  $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filename)
  Write-Verbose "Shadow copying '$filename' (version $($version.FileVersion)) to $shadowCopyFolder"
  Copy-Item $filename $shadowCopyFolder

  $filename = "${env:ProgramFiles}\Octopus Deploy\Octopus\Octopus.Client.dll"
  $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filename)
  Write-Verbose "Shadow copying '$filename' (version $($version.FileVersion)) to $shadowCopyFolder"
  Copy-Item $filename $shadowCopyFolder

  $filename = "${env:ProgramFiles}\Octopus Deploy\Octopus\Octopus.Client.Extensibility.dll"
  if (Test-Path $filename) {
    $version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filename)
    Write-Verbose "Shadow copying '$filename' (version $($version.FileVersion)) to $shadowCopyFolder"
    Copy-Item $filename $shadowCopyFolder
  }

  #shadow copy these files, so we can uninstall octopus
  Add-Type -Path (Join-Path $shadowCopyFolder "Newtonsoft.Json.dll")
  Add-Type -Path (Join-Path $shadowCopyFolder "Octopus.Client.dll")

  if (($null -ne $OctopusApiKey) -and ($OctopusApiKey -ne [PSCredential]::Empty)) {
    $apiKey = $OctopusApiKey.GetNetworkCredential().Password
    $endpoint = New-Object Octopus.Client.OctopusServerEndpoint($Url, $apiKey)
    $repository = New-Object Octopus.Client.OctopusRepository $endpoint
  }
  else {
    #connect
    $endpoint = New-Object Octopus.Client.OctopusServerEndpoint $Url
    $repository = New-Object Octopus.Client.OctopusRepository $endpoint

    #sign in
    $credentials = New-Object Octopus.Client.Model.LoginCommand
    $credentials.Username = $OctopusCredentials.GetNetworkCredential().Username
    $credentials.Password = $OctopusCredentials.GetNetworkCredential().Password
    $repository.Users.SignIn($credentials)
  }

  return $repository
}
