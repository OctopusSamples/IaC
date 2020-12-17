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
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [string[]]$SpaceManagersTeamMembers,
        [string[]]$SpaceManagersTeams,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    if (($null -eq $SpaceManagersTeamMembers) -and ($null -eq $SpaceManagersTeams)) {
        throw "Please provide at least one of 'SpaceManagersTeamMembers' or 'SpaceManagersTeams'."
    }

    $space = Get-Space -Url $Url `
        -Name $Name `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey
    $existingEnsure = 'Present'
    if ($null -eq $space) {
        $existingEnsure = 'Absent'
    }

    $result = @{
        Url                      = $Url
        Ensure                   = $existingEnsure
        Name                     = $Name
        Description              = $space.Description
        OctopusCredentials       = $OctopusCredentials
        OctopusApiKey            = $OctopusApiKey
        SpaceManagersTeamMembers = $space.SpaceManagersTeamMembers
        SpaceManagersTeams       = $space.SpaceManagersTeams
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
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [string[]]$SpaceManagersTeamMembers,
        [string[]]$SpaceManagersTeams,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    $currentResource = Get-TargetResource -Url $Url `
        -Ensure $Ensure `
        -Name $Name `
        -Description $Description `
        -SpaceManagersTeamMembers $SpaceManagersTeamMembers `
        -SpaceManagersTeams $SpaceManagersTeams `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    if ($Ensure -eq "Absent" -and $currentResource.Ensure -eq "Present") {
        Remove-Space -Url $Url `
            -Name $Name `
            -OctopusCredentials $OctopusCredentials `
            -OctopusApiKey $OctopusApiKey
    } elseif ($Ensure -eq "Present" -and $currentResource.Ensure -eq "Absent") {
        New-Space -Url $Url `
            -Name $Name `
            -Description $Description `
            -SpaceManagersTeamMembers $SpaceManagersTeamMembers `
            -SpaceManagersTeams $SpaceManagersTeams `
            -OctopusCredentials $OctopusCredentials `
            -OctopusApiKey $OctopusApiKey
    } else {
        Update-Space -Url $Url `
            -Name $Name `
            -Description $Description `
            -SpaceManagersTeamMembers $SpaceManagersTeamMembers `
            -SpaceManagersTeams $SpaceManagersTeams `
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
        [string]$Name,
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [string[]]$SpaceManagersTeamMembers,
        [string[]]$SpaceManagersTeams,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )
    $currentResource = (Get-TargetResource -Url $Url `
            -Ensure $Ensure `
            -Name $Name `
            -Description $Description `
            -SpaceManagersTeamMembers $SpaceManagersTeamMembers `
            -SpaceManagersTeams $SpaceManagersTeams `
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

function Remove-Space {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Name,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    $space = $repository.Spaces.FindByName($Name)

    $space.TaskQueueStopped = $true
    $repository.Spaces.Modify($space)

    # todo: we should probably check to make sure the task queue is empty

    $repository.Spaces.Delete($space)
}

function New-Space {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Description,
        [string[]]$SpaceManagersTeamMembers,
        [string[]]$SpaceManagersTeams,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )
    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    $space = New-SpaceResource
    $space.Name = $Name;
    $space.Description = $Description;
    $space.SpaceManagersTeamMembers = $SpaceManagersTeamMembers;
    $space.SpaceManagersTeams = $SpaceManagersTeams;

    $users = $repository.Users.FindAll()
    $space.SpaceManagersTeamMembers = ConvertTo-ReferenceCollection @($SpaceManagersTeamMembers | foreach-object {
        $user = $_
        ($users | where-object { $_.Username -eq $user }).Id
    })
    $teams = $repository.Teams.FindAll() | where-object { ($null -eq $_.SpaceId) -or ($_.SpaceId -eq $space.Id) }
    $space.SpaceManagersTeams = ConvertTo-ReferenceCollection @($SpaceManagersTeams | foreach-object {
        $team = $_
        ($teams | where-object { $_.Name -eq $team }).Id
    })

    $repository.Spaces.Create($space) | Out-Null
}

function New-SpaceResource {
    # making this mockable, so we dont have to reference Octopus.Client.dll in the tests
    return New-Object Octopus.Client.Model.SpaceResource
}

function ConvertTo-ReferenceCollection ([string[]]$list) {
    # making this mockable, so we dont have to reference Octopus.Client.dll in the tests
    return New-Object Octopus.Client.Model.ReferenceCollection ($list)
}

function Update-Space {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Description,
        [string[]]$SpaceManagersTeamMembers,
        [string[]]$SpaceManagersTeams,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )
    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    $space = $repository.Spaces.FindByName($Name)
    $space.Description = $Description

    $users = $repository.Users.FindAll()
    $space.SpaceManagersTeamMembers = @($SpaceManagersTeamMembers | foreach-object {
        $user = $_
        ($users | where-object { $_.Username -eq $user }).Id
    })
    $teams = $repository.Teams.FindAll() | where-object { ($null -eq $_.SpaceId) -or ($_.SpaceId -eq $space.Id) }
    $space.SpaceManagersTeams = @($SpaceManagersTeams | foreach-object {
        $team = $_
        ($teams | where-object { $_.Name -eq $team }).Id
    })
    if ($null -eq ($SpaceManagersTeams | where-object { $_ -eq 'Space Managers' })) {
        $space.SpaceManagersTeams += ($teams | where-object { $_.Name -eq 'Space Managers'}).Id
    }
    $repository.Spaces.Modify($space) | Out-Null
}

function Get-Space {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$Name,
        [PSCredential]$OctopusCredentials = [PSCredential]::Empty,
        [PSCredential]$OctopusApiKey = [PSCredential]::Empty
    )

    $repository = Get-OctopusClientRepository -Url $Url `
        -OctopusCredentials $OctopusCredentials `
        -OctopusApiKey $OctopusApiKey

    $space = $repository.Spaces.FindByName($Name)

    if ($null -ne $space) {
        # convert to json and back again, so we've got a HashTable rather than a SpaceResource
        # need a HashTable instead, as we want string[] for SpaceManagersTeamMembers and SpaceManagersTeams
        $space = ($space | ConvertTo-Json -depth 10 | ConvertFrom-Json)
        $users = $repository.Users.FindAll()
        $teams = $repository.Teams.FindAll() | where-object { ($null -eq $_.SpaceId) -or ($_.SpaceId -eq $space.Id) }
        $space.SpaceManagersTeamMembers = $space.SpaceManagersTeamMembers | foreach-object {
            $user = $_
            ($users | where-object { $_.Id -eq $user }).Username
        }
        $space.SpaceManagersTeams = $space.SpaceManagersTeams | foreach-object {
            $team = $_
            ($teams | where-object { $_.Id -eq $team }).Name
        }
    }

    # convert to json and back again, so we've got a HashTable rather than a SpaceResource
    # need a HashTable instead, as we want string[] for SpaceManagersTeamMembers and SpaceManagersTeams
    return $space
}

function Get-OctopusClientRepository {
    param (
        [Parameter(Mandatory)]
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
