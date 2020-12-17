$octopusServerExePath = "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe"
$tentacleExePath = "$($env:ProgramFiles)\Octopus Deploy\Tentacle\Tentacle.exe"

# dot-source the helper file (cannot load as a module due to scope considerations)
. (Join-Path -Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -ChildPath 'OctopusDSCHelpers.ps1')

function Get-TargetResource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [OutputType([HashTable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OctopusServer", "Tentacle")]
        [string]$InstanceType,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [string]$SeqServer,
        [PSCredential]$SeqApiKey,
        [Microsoft.Management.Infrastructure.CimInstance[]]$Properties,
        [int]$ConfigVersion
    )

    $propertiesAsHashTable = ConvertTo-HashTable $properties
    return Get-TargetResourceInternal -InstanceType $InstanceType `
        -Ensure $Ensure `
        -SeqServer $SeqServer `
        -SeqApiKey $SeqApiKey `
        -Properties $propertiesAsHashTable `
        -ConfigVersion $ConfigVersion
}

function Set-TargetResource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OctopusServer", "Tentacle")]
        [string]$InstanceType,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [string]$SeqServer,
        [PSCredential]$SeqApiKey,
        [Microsoft.Management.Infrastructure.CimInstance[]]$Properties,
        [int]$ConfigVersion
    )
    $propertiesAsHashTable = ConvertTo-HashTable $properties
    Set-TargetResourceInternal -InstanceType $InstanceType `
        -Ensure $Ensure `
        -SeqServer $SeqServer `
        -SeqApiKey $SeqApiKey `
        -Properties $propertiesAsHashTable `
        -ConfigVersion $ConfigVersion
}

function Test-TargetResource {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OctopusServer", "Tentacle")]
        [string]$InstanceType,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [string]$SeqServer,
        [PSCredential]$SeqApiKey,
        [Microsoft.Management.Infrastructure.CimInstance[]]$Properties,
        [int]$ConfigVersion
    )

    $propertiesAsHashTable = ConvertTo-HashTable $properties
    return Test-TargetResourceInternal -InstanceType $InstanceType `
        -Ensure $Ensure `
        -SeqServer $SeqServer `
        -SeqApiKey $SeqApiKey `
        -Properties $propertiesAsHashTable `
        -ConfigVersion $ConfigVersion
}

function Get-TargetResourceInternal {
    [OutputType([Hashtable])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OctopusServer", "Tentacle")]
        [string]$InstanceType,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [string]$SeqServer,
        [PSCredential]$SeqApiKey,
        [HashTable]$Properties,
        [int]$ConfigVersion
    )

    if (-not (Test-Path -Path $octopusServerExePath) -and ($InstanceType -eq "OctopusServer") -and ($Ensure -eq "Present")) {
        throw "Unable to find Octopus (checked for existence of file '$octopusServerExePath')."
    }
    if (-not (Test-Path -Path $tentacleExePath) -and ($InstanceType -eq "Tentacle") -and ($Ensure -eq "Present")) {
        throw "Unable to find Tentacle (checked for existence of file '$tentacleExePath')."
    }

    if ($InstanceType -eq "Tentacle") {
        $nlogConfigFile = "$tentacleExePath.nlog"
    }
    elseif ($InstanceType -eq "OctopusServer") {
        $nlogConfigFile = "$octopusServerExePath.nlog"
    }

    $existingApiKey = $null
    $nlogExtensionElementExists = $false
    $nlogTargetElementExists = $false
    $nlogRuleElementExists = $false
    $existingServerUrl = $null
    $existingProperties = @{}

    if (Test-Path $nlogConfigFile) {

        $nlogConfig = Get-NLogConfig $nlogConfigFile
        $nlogExtensionElementExists = $null -ne ($nlogConfig.nlog.extensions.add.assembly | where-object { $_ -eq "Seq.Client.Nlog" })
        $nlogTargetElement = ($nlogConfig.nlog.targets.target | where-object {$_.name -eq "seq" -and $_.type -eq "Seq"})
        $nlogTargetElementExists = $null -ne $nlogTargetElement
        $nlogRuleElement = ($nlogConfig.nlog.rules.logger | where-object {$_.writeTo -eq "seq"})
        $nlogRuleElementExists = $null -ne $nlogRuleElement

        $nlogBufferingWrapperElement = ($nlogConfig.nlog.targets.target | where-object {$_.name -eq "seqbufferingwrapper" -and $_.type -eq "BufferingWrapper"})
        $nlogBufferingWrapperElementExists = $null -ne $nlogBufferingWrapperElement
        $nlogBufferingWrapperRuleElement = ($nlogConfig.nlog.rules.logger | where-object {$_.writeTo -eq "seqbufferingwrapper"})
        $nlogBufferingWrapperRuleElementExists = $null -ne $nlogBufferingWrapperRuleElement

        if ($nlogTargetElementExists) {
            $configVersion = 1
            $plainTextPassword = ($nlogConfig.nlog.targets.target | where-object { $_.name -eq "seq" -and $_.type -eq "Seq" }).ApiKey
            if ($null -ne $plainTextPassword) {
                $password = new-object securestring
                # Avoid using "ConvertTo-SecureString ... -AsPlaintext", to fix PSAvoidUsingConvertToSecureStringWithPlainText
                # Not sure it actually solves the underlying issue though
                $plainTextPassword.ToCharArray() | Foreach-Object { $password.AppendChar($_) }
                $existingApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $password)
            }
            $existingServerUrl = $nlogTargetElement.serverUrl
            if ($null -ne $nlogTargetElementExists -and ($null -ne $nlogTargetElement.property)) {
                $nlogTargetElement.property | Sort-Object -Property Name | Foreach-Object { $existingProperties[$_.name] = $_.value }
            }
        } elseif ($nlogBufferingWrapperElementExists) {
            $configVersion = 2
            $nlogTargetElement = ($nlogConfig.nlog.targets.target | where-object { $_.name -eq "seqbufferingwrapper" -and $_.type -eq "BufferingWrapper" }).target | where-object { $_.name -eq "seq" -and $_.type -eq "Seq"}
            $plainTextPassword = $nlogTargetElement.ApiKey
            if ($null -ne $plainTextPassword) {
                $password = new-object securestring
                # Avoid using "ConvertTo-SecureString ... -AsPlaintext", to fix PSAvoidUsingConvertToSecureStringWithPlainText
                # Not sure it actually solves the underlying issue though
                $plainTextPassword.ToCharArray() | Foreach-Object { $password.AppendChar($_) }
                $existingApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $password)
            }
            $existingServerUrl = $nlogTargetElement.serverUrl
            if ($null -ne $nlogTargetElementExists -and ($null -ne $nlogTargetElement.property)) {
                $nlogTargetElement.property | Sort-Object -Property Name | Foreach-Object { $existingProperties[$_.name] = $_.value }
            }
        }
    }

    if ($InstanceType -eq "Tentacle") {
        $dllPath = "$($env:ProgramFiles)\Octopus Deploy\Tentacle\Seq.Client.NLog.dll"
    }
    elseif ($InstanceType -eq "OctopusServer") {
        $dllPath = "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll"
    }

    $existingEnsure = "Absent"
    if ((Test-NLogDll $dllPath) -and $nlogExtensionElementExists -and (($nlogTargetElementExists -and $nlogRuleElementExists) -or ($nlogBufferingWrapperElementExists -and $nlogBufferingWrapperRuleElementExists))) {
        $existingEnsure = "Present"
    }

    $result = @{
        InstanceType  = $InstanceType;
        Ensure        = $existingEnsure
        SeqServer     = $existingServerUrl
        SeqApiKey     = $existingApiKey
        Properties    = $existingProperties
        ConfigVersion = $configVersion
    }

    return $result
}

function Set-TargetResourceInternal {
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OctopusServer", "Tentacle")]
        [string]$InstanceType,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [string]$SeqServer,
        [PSCredential]$SeqApiKey,
        [HashTable]$Properties,
        [int]$ConfigVersion
    )

    if ((($null -eq $SeqServer) -or ("" -eq $SeqServer)) -and ($Ensure -eq 'Present')) {
        throw "Property 'SeqServer' should be supplied if 'Ensure' is set to 'Present'"
    }

    Get-TargetResourceInternal -InstanceType $InstanceType `
        -Ensure $Ensure `
        -SeqServer $SeqServer `
        -SeqApiKey $SeqApiKey `
        -Properties $Properties `
        -ConfigVersion $ConfigVersion

    if ($InstanceType -eq "Tentacle") {
        $dllPath = "$($env:ProgramFiles)\Octopus Deploy\Tentacle\Seq.Client.NLog.dll"
    }
    elseif ($InstanceType -eq "OctopusServer") {
        $dllPath = "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll"
    }

    if ($InstanceType -eq "Tentacle") {
        $nlogConfigFile = "$tentacleExePath.nlog"
    }
    elseif ($InstanceType -eq "OctopusServer") {
        $nlogConfigFile = "$octopusServerExePath.nlog"
    }

    if ($Ensure -eq "Absent") {
        if (Test-Path $dllPath) {
            try {
                Remove-Item $dllPath -Force -ErrorAction SilentlyContinue
            }
            catch {
                Write-Verbose "We tried to removing the seq dll from $dllPath"
                Write-Verbose "But, we couldn't actually remove it, as its locked by Octopus.Server.exe / Tentacle.exe"
            }
        }
        if (Test-Path $nlogConfigFile) {
            Write-Verbose "Removing settings from $nlogConfigFile"
            $nlogConfig = Get-NLogConfig $nlogConfigFile

            $nlogExtensionElement = ($nlogConfig.nlog.extensions.add | where-object { $_.assembly -eq "Seq.Client.NLog" })
            if ($null -ne $nlogExtensionElement) {
                $nlogConfig.nlog.extensions.RemoveChild($nlogExtensionElement)
            }
            $nlogTargetElement = ($nlogConfig.nlog.targets.target | where-object { ($_.name -eq 'seq' -and $_.type -eq 'Seq') -or ($_.name -eq 'seqbufferingwrapper' -and $_.type -eq 'BufferingWrapper')})
            if ($null -ne $nlogTargetElement) {
                $nlogConfig.nlog.targets.RemoveChild($nlogTargetElement)
            }
            $nlogRuleElement = ($nlogConfig.nlog.rules.logger | where-object {$_.writeTo -eq 'seq' -or $_.writeTo -eq 'seqbufferingwrapper'})
            if ($null -ne $nlogRuleElement) {
                $nlogConfig.nlog.rules.RemoveChild($nlogRuleElement)
            }
            Write-Verbose "Saving updated config file $nlogConfigFile"
            Save-NlogConfig $nlogConfig $nlogConfigFile
        }
    }
    else {
        if (-not (Test-Path $dllPath)) {
            Request-SeqClientNlogDll $dllPath
        }
        Write-Verbose "Modifying config file $nlogConfigFile"
        $nlogConfig = Get-NLogConfig $nlogConfigFile

        #remove then re-add "<add assembly="Seq.Client.NLog"/>" to //nlog/extensions
        $nlogExtensionElement = ($nlogConfig.nlog.extensions.add | where-object { $_.assembly -eq "Seq.Client.NLog" })
        if ($null -ne $nlogExtensionElement) {
            $nlogConfig.nlog.extensions.RemoveChild($nlogExtensionElement)
        }
        $newChild = $nlogConfig.CreateElement("add", $nlogConfig.DocumentElement.NamespaceURI)
        $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "assembly"  -value "Seq.Client.NLog"))
        $nlogConfig.nlog.extensions.AppendChild($newChild)

        #remove then re-add "
        #  <target name="seq" xsi:type="Seq" serverUrl="https://seq.example.com" apiKey="my-magic-api-key">
        #    <property name="Application" value="Octopus" />
        #  </target>
        #to //nlog/targets"
        $nlogTargetElement = ($nlogConfig.nlog.targets.target | where-object { ($_.name -eq "seq" -and $_.type -eq "Seq") -or ($_.name -eq "seqbufferingwrapper" -and $_.type -eq 'BufferingWrapper')})
        if ($null -ne $nlogTargetElement) {
            $nlogConfig.nlog.targets.RemoveChild($nlogTargetElement)
        }
        $newBufferingWrapperChild = $nlogConfig.CreateElement("target", $nlogConfig.DocumentElement.NamespaceURI)
        $newBufferingWrapperChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "name" -value "seqbufferingwrapper"))
        $attribute = $nlogConfig.CreateAttribute("xsi:type", "http://www.w3.org/2001/XMLSchema-instance")
        $attribute.Value = "BufferingWrapper"
        $newBufferingWrapperChild.Attributes.Append($attribute)
        $newBufferingWrapperChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "bufferSize" -value "1000"))
        $newBufferingWrapperChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "flushTimeout" -value "2000"))

        $newChild = $nlogConfig.CreateElement("target", $nlogConfig.DocumentElement.NamespaceURI)
        $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "name" -value "seq"))
        $attribute = $nlogConfig.CreateAttribute("xsi:type", "http://www.w3.org/2001/XMLSchema-instance")
        $attribute.Value = "Seq"
        $newChild.Attributes.Append($attribute)
        $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "serverUrl" -value $SeqServer))
        if ($null -ne $SeqApiKey) {
            $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "apiKey" -value $SeqApiKey.GetNetworkCredential().Password))
        }
        if ($null -ne $properties) {
            $sortedProperties = ($Properties.GetEnumerator() | Sort-Object -Property Key)
            foreach ($property in $sortedProperties) {
                $propertyChild = $nlogConfig.CreateElement("property", $nlogConfig.DocumentElement.NamespaceURI)
                $propertyChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "name" -value $property.Key))
                $propertyChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "value" -value $property.value))
                $newChild.AppendChild($propertyChild)
            }
        }
        $newBufferingWrapperChild.AppendChild($newChild)
        $nlogConfig.nlog.targets.AppendChild($newBufferingWrapperChild)

        # remove then re-add "<logger name="*" minlevel="Info" writeTo="seqbufferingwrapper" />" to //nlog/rules"
        $nlogRuleElement = ($nlogConfig.nlog.rules.logger | where-object {$_.writeTo -eq "seq" -or $_.writeTo -eq "seqbufferingwrapper" })
        if ($null -ne $nlogRuleElement) {
            $nlogConfig.nlog.rules.RemoveChild($nlogRuleElement)
        }
        $newChild = $nlogConfig.CreateElement("logger", $nlogConfig.DocumentElement.NamespaceURI)
        $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "name" -value "*"))
        $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "minlevel" -value "Info"))
        $newChild.Attributes.Append((New-XmlAttribute -xml $nlogConfig -name "writeTo" -value "seqbufferingwrapper"))
        $nlogConfig.nlog.rules.AppendChild($newChild)

        Write-Verbose "Saving config file $nlogConfigFile"
        Save-NlogConfig $nlogConfig $nlogConfigFile
    }
}

function Test-TargetResourceInternal {
    [OutputType([boolean])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OctopusServer", "Tentacle")]
        [string]$InstanceType,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,
        [string]$SeqServer,
        [PSCredential]$SeqApiKey,
        [HashTable]$Properties,
        [int]$ConfigVersion
    )
    $currentResource = (Get-TargetResourceInternal -InstanceType $InstanceType `
            -Ensure $Ensure `
            -SeqServer $SeqServer `
            -SeqApiKey $SeqApiKey `
            -Properties $Properties `
            -ConfigVersion $ConfigVersion)

    $params = Get-ODSCParameter $MyInvocation.MyCommand.Parameters

    $currentConfigurationMatchesRequestedConfiguration = $true
    foreach ($key in $currentResource.Keys) {
        $currentValue = $currentResource.Item($key)
        $requestedValue = $params.Item($key)

        if ($currentValue -is [PSCredential]) {
            if (-not (Test-PSCredential $currentValue $requestedValue)) {
                $currentConfigurationMatchesRequestedConfiguration = $false
            }
        }
        elseif ($currentValue -is [HashTable]) {
            if (-not (Test-HashTable $currentValue $requestedValue)) {
                $currentConfigurationMatchesRequestedConfiguration = $false
            }
        }
        elseif ($currentValue -ne $requestedValue) {
            Write-Verbose "(FOUND MISMATCH) Configuration parameter '$key' with value '$currentValue' mismatched the specified value '$requestedValue'"
            $currentConfigurationMatchesRequestedConfiguration = $false
        }
        else {
            Write-Verbose "Configuration parameter '$key' matches the requested value '$requestedValue'"
        }
    }

    if ($currentResource['ConfigVersion'] -eq 1) {
        Write-Verbose "Current configuration is in the old, synchronous format, which can cause issues when seq has a hiccup."
        $currentConfigurationMatchesRequestedConfiguration = $false
    }

    return $currentConfigurationMatchesRequestedConfiguration
}

function Get-NLogConfig ([string] $fileName) {
    return [xml] (Get-Content $fileName)
}

function Test-NLogDll ([string] $fileName) {
    return Test-Path $fileName
}

function New-XmlAttribute($xml, $name, $value) {
    $attribute = $xml.CreateAttribute($name)
    $attribute.Value = $value
    return $attribute
}

function ConvertTo-HashTable {
    [CmdletBinding()]
    [OutputType([HashTable])]
    param
    (
        [Microsoft.Management.Infrastructure.CimInstance[]] $tokens
    )
    $HashTable = @{}
    foreach ($token in $tokens) {
        $HashTable.Add($token.Key, $token.Value)
    }
    return $HashTable
}

function Request-SeqClientNlogDll ($dllPath) {
    Write-Verbose "Downloading Seq.Client.NLog.dll version 2.3.27 from nuget to $dllPath"

    $ProgressPreference = "SilentlyContinue"
    $folder = [System.IO.Path]::GetTempPath()
    Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -outfile "$folder\nuget.exe"
    & "$folder\nuget.exe" install Seq.Client.NLog -outputdirectory $folder -version 2.3.27
    Copy-Item "$folder\Seq.Client.NLog.2.3.27\lib\net40\Seq.Client.NLog.dll" $dllPath
}

function Save-NlogConfig ($nlogConfig, $filename) {
    $nlogConfig.Save($filename)
}

function Test-HashTable($currentValue, $requestedValue) {
    $currentConfigurationMatchesRequestedConfiguration = $true
    if ($currentValue.Count -ne $requestedValue.Count) {
        Write-Verbose "(FOUND MISMATCH) Configuration parameter '$key' with $($currentValue.count) values mismatched the specified $($requestedValue.Count) values"
        $currentConfigurationMatchesRequestedConfiguration = $false
    }
    else {
        foreach ($value in $currentValue.Keys) {
            $curr = $currentValue[$value]
            $req = $requestedValue[$value]
            if ($curr -ne $req) {
                Write-Verbose "(FOUND MISMATCH) Configuration parameter `"$key['$value']`" with value '$curr' mismatched the specified value '$req'"
                $currentConfigurationMatchesRequestedConfiguration = $false
            }
        }
    }
    return $currentConfigurationMatchesRequestedConfiguration
}

function Test-PSCredential($currentValue, $requestedValue) {
    if ($null -ne $currentValue) {
        $currentUsername = $currentValue.GetNetworkCredential().UserName
        $currentPassword = $currentValue.GetNetworkCredential().Password
    }
    else {
        $currentUserName = ""
        $currentPassword = ""
    }

    if ($null -ne $requestedValue) {
        $requestedUsername = $requestedValue.GetNetworkCredential().UserName
        $requestedPassword = $requestedValue.GetNetworkCredential().Password
    }
    else {
        $requestedUsername = ""
        $requestedPassword = ""
    }

    if ($currentPassword -ne $requestedPassword -or $currentUsername -ne $requestedUserName) {
        Write-Verbose "(FOUND MISMATCH) Configuration parameter '$key' with value '********' mismatched the specified value '********'"
        return $false
    }
    else {
        Write-Verbose "Configuration parameter '$key' matches the requested value '********'"
    }
    return $true
}
