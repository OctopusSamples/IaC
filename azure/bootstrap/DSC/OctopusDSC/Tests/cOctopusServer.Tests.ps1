#requires -Version 4.0
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

$moduleName = Split-Path ($PSCommandPath -replace '\.Tests\.ps1$', '') -Leaf
$modulePath = Resolve-Path "$PSCommandPath/../../DSCResources/$moduleName/$moduleName.psm1"
$module = $null

try
{
    $prefix = [guid]::NewGuid().Guid -replace '-'

    $module = Import-Module $modulePath -Prefix $prefix -PassThru -ErrorAction Stop

    InModuleScope $module.Name {

        Describe 'cOctopusServer' {
            BeforeAll {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $mockConfig = [pscustomobject] @{
                    OctopusStorageExternalDatabaseConnectionString         = 'StubConnectionString'
                    OctopusWebPortalListenPrefixes                         = "https://octopus.example.com,http://localhost"
                }
                Mock Import-ServerConfig { return $mockConfig }

                # Get-Service is not available on mac/unix systems - fake it
                $getServiceCommand = Get-Command "Get-Service" -ErrorAction SilentlyContinue
                if ($null -eq $getServiceCommand) {
                    function Get-Service {
                        [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidOverwritingBuiltInCmdlets', '', Justification='Get-Service is not available on mac/unix systems, so without faking it, our builds fail')]
                        param()
                    }
                }

                function Get-DesiredConfiguration {
                    $pass = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
                    $cred = New-Object System.Management.Automation.PSCredential ("Admin", $pass)

                    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                    $desiredConfiguration = @{
                        Name                   = 'Stub'
                        Ensure                 = 'Present'
                        State                  = 'Started'
                        WebListenPrefix        = "http://localhost:80"
                        SqlDbConnectionString  = "conn-string"
                        OctopusAdminCredential = $cred
                    }
                    return $desiredConfiguration
                }
            }

            Context 'Get-TargetResource' {
                Context 'When reg key exists and service exists and service started' {
                    It 'Should have Ensure=Present and State=Started' {
                        Mock Get-ItemProperty { return @{ InstallLocation = "c:\Octopus\Octopus" }}
                        Mock Get-Service { return @{ Status = "Running" }}
                        $desiredConfiguration = Get-DesiredConfiguration
                        $config = Get-TargetResource @desiredConfiguration
                        $config['Ensure']                  | Should -Be 'Present'
                        $config['State']                   | Should -Be 'Started'
                    }
                }

                Context 'When reg key exists and service exists and service stopped' {
                    It 'Should have Ensure=Present and State=Stopped' {
                        Mock Get-ItemProperty { return @{ InstallLocation = "c:\Octopus\Octopus" }}
                        Mock Get-Service { return @{ Status = "Stopped" }}
                        $desiredConfiguration = Get-DesiredConfiguration
                        $config = Get-TargetResource @desiredConfiguration
                        $config['Ensure']                  | Should -Be 'Present'
                        $config['State']                   | Should -Be 'Stopped'
                    }
                }

                Context 'When reg key exists and service does not exist' {
                    It 'Should have Ensure=Present and State=Installed' {
                        Mock Get-ItemProperty { return @{ InstallLocation = "c:\Octopus\Octopus" }}
                        Mock Get-Service { return $null }
                        $desiredConfiguration = Get-DesiredConfiguration
                        $config = Get-TargetResource @desiredConfiguration
                        $config['Ensure']                  | Should -Be 'Present'
                        $config['State']                   | Should -Be 'Installed'
                    }
                }

                Context 'When reg key does not exist and service does not exist' {
                    It 'Should have Ensure=Absent and State=Stopped' {
                        Mock Get-ItemProperty { return $null }
                        Mock Get-Service { return $null }
                        $desiredConfiguration = Get-DesiredConfiguration
                        $config = Get-TargetResource @desiredConfiguration
                        $config['Ensure']                  | Should -Be 'Absent'
                        $config['State']                   | Should -Be 'Stopped'
                    }
                }

                Context 'When reg key does not exist and service started' {
                    It 'Should have Ensure=Present and State=Started' {
                        Mock Get-ItemProperty { return $null }
                        Mock Get-Service { return @{ Status = "Running" } }
                        $desiredConfiguration = Get-DesiredConfiguration
                        $config = Get-TargetResource @desiredConfiguration
                        $config['Ensure']                  | Should -Be 'Present'
                        $config['State']                   | Should -Be 'Started'
                    }
                }

                Context 'When reg key does not exist and service stopped' {
                    It 'Should have Ensure=Present and State=Stopped' {
                        Mock Get-ItemProperty { return $null }
                        Mock Get-Service { return @{ Status = "Stopped" } }
                        $desiredConfiguration = Get-DesiredConfiguration
                        $config = Get-TargetResource @desiredConfiguration
                        $config['Ensure']                  | Should -Be 'Present'
                        $config['State']                   | Should -Be 'Stopped'
                    }
                }

                function Get-PropertiesFromMof() {
                    $moduleName = Split-Path ($PSCommandPath -replace '\.Tests\.ps1$', '') -Leaf
                    $modulePath = Resolve-Path "$PSCommandPath/../../DSCResources/$moduleName/$moduleName.psm1"
                    $mofFile = Get-Item ($modulePath -replace ".psm1", ".schema.mof")
                    $schemaMofFileContent = Get-Content $mofFile

                    $properties = @()
                    foreach($line in $schemaMofFileContent) {
                        if ($line -match "\s*(\[.*\])\s*(.*) (.*);") {
                            $attributes = $matches[1];
                            if ($attributes -like '*MSFT_Credential*') {
                                $propertyType = 'PSCredential';
                            } else {
                                $propertyType = $matches[2];
                            }
                            $propertyName = $matches[3].Replace("[]", "");

                            $properties += @{ propertyType = $propertyType; propertyName = $propertyName };
                        }
                    }
                    return $properties
                }

                Context "Should return a hash table that lists all the resource properties as keys and the actual values" {
                    # Get-Service is not available on mac/unix systems - fake it
                    $getServiceCommand = Get-Command "Get-Service" -ErrorAction SilentlyContinue
                    if ($null -eq $getServiceCommand) {
                        function Get-Service {
                            [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidOverwritingBuiltInCmdlets', '', Justification='Get-Service is not available on mac/unix systems, so without faking it, our builds fail')]
                            param()
                        }
                    }

                    $desiredConfiguration = @{
                        Name                   = 'Stub'
                        Ensure                 = 'Present'
                        State                  = 'Started'
                        WebListenPrefix        = "http://localhost:80"
                        SqlDbConnectionString  = "conn-string"
                        OctopusAdminCredential = New-Object System.Management.Automation.PSCredential ("Admin", (ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force))
                    }
                    $currentState = Get-TargetResource @desiredConfiguration
                    $expectedProperties = Get-PropertiesFromMof;
                    $testCases = @()
                    foreach($expectedProperty in $expectedProperties) {
                        $propertyReturned = $currentState.ContainsKey($expectedProperty.PropertyName);
                        $propertyMatches = $false;
                        if ($propertyReturned) {
                            $value = $currentState[$expectedProperty.PropertyName];
                            if ($null -ne $value) {
                                $propertyMatches = $value.GetType().Name -eq $expectedProperty.PropertyType;
                            }
                        }

                        $testCases += @{
                            propertyName = $expectedProperty.PropertyName;
                            PropertyType = $expectedProperty.PropertyType;
                            propertyReturned = $propertyReturned;
                            propertyMatches = $propertyMatches;
                         }
                    }

                    it "should return a hashtable with an entry for <propertyName>" -TestCases $testCases {
                        param($propertyName, $propertyReturned)
                        write-verbose "Property $propertyName should exist" # to keep psscriptanalyzer from complaining about PSReviewUnusedParameter
                        $propertyReturned | Should -Be $true
                    }

                    it "should return a <propertyType> value for <propertyName>" -TestCases $testCases {
                        param($propertyName, $propertyMatches)
                        write-verbose "Property $propertyName should exist" # to keep psscriptanalyzer from complaining about PSReviewUnusedParameter
                        $propertyMatches | Should -Be $true
                    }
                }
            }

            Context "Parameter Validation" {
                Context "Ensure = 'Present' and 'State' = 'Stopped'" {
                    It "Should throw if 'Name' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -DownloadUrl "blah2" } `
                            | Should -throw "Parameter 'Name' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'DownloadUrl' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" } `
                            | Should -throw "Parameter 'DownloadUrl' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'WebListenPrefix' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" } `
                            | Should -throw "Parameter 'WebListenPrefix' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3"} `
                            | Should -throw "Parameter 'SqlDbConnectionString' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'TaskCap' is less than 1" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds -TaskCap -1} `
                            | Should -throw "Parameter 'TaskCap' must be greater than 0 when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'TaskCap' is greater than 50" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds -TaskCap 51} `
                            | Should -throw "Parameter 'TaskCap' must be less than 50 when 'Ensure' is 'Present'."
                    }
                    It "Should not throw if 'OctopusAdminCredential' not supplied but 'OctopusMasterKey' is supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null -OctopusMasterKey $creds} | Should -not -throw
                    }
                    It "Should not throw if 'OctopusAdminCredential' is '[PSCredential]::Empty' but 'OctopusMasterKey' is supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusMasterKey $creds} | Should -not -throw
                    }
                    It "Should throw if 'OctopusAdminCredential' not supplied and 'OctopusMasterKey' is not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" } `
                            | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should throw if 'OctopusAdminCredential' is null and 'OctopusMasterKey' is null" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null -OctopusMasterKey $null } `
                            | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should throw if 'OctopusAdminCredential' is '[PSCredential]::Empty' and 'OctopusMasterKey' is '[PSCredential]::Empty'" {
                        $creds = [PSCredential]::Empty
                        $masterKey = [PSCredential]::Empty
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds -OctopusMasterKey $masterKey } `
                            | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should not throw if all params are supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds} | Should -not -throw
                    }
                }

                Context "Ensure = 'Present' and 'State' = 'Started'" {
                    It "Should throw if 'Name' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Stopped' -DownloadUrl "blah2" } | Should -throw "Parameter 'Name' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'DownloadUrl' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" } | Should -throw "Parameter 'DownloadUrl' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'WebListenPrefix' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" } | Should -throw "Parameter 'WebListenPrefix' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should throw if 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3"} | Should -throw "Parameter 'SqlDbConnectionString' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should not throw if 'OctopusAdminCredential' not supplied but 'OctopusMasterKey' is supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null -OctopusMasterKey $creds} | Should -not -throw
                    }
                    It "Should not throw if 'OctopusAdminCredential' is '[PSCredential]::Empty' but 'OctopusMasterKey' is supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusMasterKey $creds} | Should -not -throw
                    }
                    It "Should throw if 'OctopusAdminCredential' not supplied and 'OctopusMasterKey' is not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" } | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should throw if 'OctopusAdminCredential' is null and 'OctopusMasterKey' is null" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null -OctopusMasterKey $null } | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should throw if 'OctopusAdminCredential' is '[PSCredential]::Empty' and 'OctopusMasterKey' is '[PSCredential]::Empty'" {
                        $creds = [PSCredential]::Empty
                        $masterKey = [PSCredential]::Empty
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds -OctopusMasterKey $masterKey } | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should not throw if all params are supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds} | Should -not -throw
                    }
                }

                Context "Ensure = 'Present' and 'State' = 'Installed'" {
                    It "Should not throw if 'Name' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' -DownloadUrl "blah2" } | Should -not -throw
                    }
                    It "Should throw if 'DownloadUrl' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' } | Should -throw "Parameter 'DownloadUrl' must be supplied when 'Ensure' is 'Present'."
                    }
                    It "Should not throw if 'WebListenPrefix' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' -DownloadUrl "blah2" } | Should -not -throw
                    }
                    It "Should not throw if 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' -DownloadUrl "blah2" -WebListenPrefix "blah3"} | Should -not -throw
                    }
                    It "Should not throw if 'OctopusAdminCredential' not supplied and 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' -DownloadUrl "blah2" -WebListenPrefix "blah3" -OctopusAdminCredential $null } | Should -not -throw
                    }
                    It "Should not throw if 'OctopusAdminCredential' is '[PSCredential]::Empty' and 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' -DownloadUrl "blah2" -WebListenPrefix "blah3" } | Should -not -throw
                    }
                    It "Should not throw if all params are supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Present' -State 'Installed' -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds} | Should -not -throw
                    }
                }

                Context "Ensure = 'Present', 'State' = 'Installed', and 'SqlDbConnectionString' != 'null or empty'" {
                    It "Should throw if 'OctopusAdminCredential' not supplied and 'OctopusMasterKey' is not supplied" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" } | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should throw if 'OctopusAdminCredential' is null and 'OctopusMasterKey' is null" {
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null -OctopusMasterKey $null } | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                    It "Should throw if 'OctopusAdminCredential' is '[PSCredential]::Empty' and 'OctopusMasterKey' is '[PSCredential]::Empty'" {
                        $creds = [PSCredential]::Empty
                        $masterKey = [PSCredential]::Empty
                        { Test-ParameterSet -Ensure 'Present' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds -OctopusMasterKey $masterKey } | Should -throw "Parameter 'OctopusAdminCredential' must be supplied when 'Ensure' is 'Present' and you have not supplied a master key to use an existing database."
                    }
                }

                Context "Ensure = 'Absent' and 'State' = 'Stopped'" {
                    It "Should throw if 'Name' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' } | Should -throw "Parameter 'Name' must be supplied when 'Ensure' is 'Absent'."
                    }
                    It "Should not throw if 'DownloadUrl' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' -Name "blah1" } | Should -not -throw
                    }
                    It "Should not throw if 'WebListenPrefix' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" } | Should -not -throw
                    }
                    It "Should not throw if 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3"} | Should -not -throw
                    }
                    It "Should not throw if 'OctopusAdminCredential' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null} | Should -not -throw
                    }
                    It "Should not throw if 'OctopusAdminCredential' is '[PSCredential]::Empty'" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4"} | Should -not -throw
                    }
                    It "Should not throw if all params are supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Absent' -State 'Stopped' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds} | Should -not -throw
                    }
                }

                Context "Ensure = 'Absent' and 'State' = 'Started'" {
                    It "Should throw if 'Name' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' } | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'DownloadUrl' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' -Name "blah1"} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'WebListenPrefix' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' -Name "blah1" -DownloadUrl "blah2" } | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3"} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'OctopusAdminCredential' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'OctopusAdminCredential' is '[PSCredential]::Empty'" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4"} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if all params are supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Absent' -State 'Started' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"."
                    }
                }

                Context "Ensure = 'Absent' and 'State' = 'Installed'" {
                    It "Should throw if 'Name' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' } | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'DownloadUrl' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' -Name "blah1"} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'WebListenPrefix' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' -Name "blah1" -DownloadUrl "blah2" } | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'SqlDbConnectionString' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3"} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'OctopusAdminCredential' not supplied" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $null} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if 'OctopusAdminCredential' is '[PSCredential]::Empty'" {
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4"} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                    It "Should throw if all params are supplied" {
                        $creds = New-Object System.Management.Automation.PSCredential ("username", (new-object System.Security.SecureString))
                        { Test-ParameterSet -Ensure 'Absent' -State 'Installed' -Name "blah1" -DownloadUrl "blah2" -WebListenPrefix "blah3" -SqlDbConnectionString "blah4" -OctopusAdminCredential $creds} | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be installed at the same time. You probably want 'State = `"Stopped`"."
                    }
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ Ensure="Absent"; State="Stopped" }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns True when Ensure is set to Absent and Instance does not exist' {
                    $desiredConfiguration = Get-DesiredConfiguration
                    $desiredConfiguration['Ensure'] = 'Absent'
                    $desiredConfiguration['State'] = 'Stopped'
                    $response['Ensure'] = 'Absent'
                    $response['State'] = 'Stopped'

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

               It 'Returns True when Ensure is set to Present and Instance exists' {
                $desiredConfiguration = Get-DesiredConfiguration
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['State'] = 'Started'
                    $response['Ensure'] = 'Present'
                    $response['State'] = 'Started'

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }
            }

            Context 'Set-TargetResource' {
                It 'Throws an exception if .net 4.5.2 or above is not installed (no .net reg key found)' {
                    Mock Test-OctopusVersionRequiresDotNet472 { return $false } # older version (pre 2019.7.0)
                    Mock Invoke-MsiExec {}
                    Mock Get-LogDirectory {}
                    Mock Request-File {}
                    Mock Get-RegistryValue { return "" }
                    Mock Update-InstallState
                    $desiredConfiguration = Get-DesiredConfiguration
                    { Set-TargetResource @desiredConfiguration } | Should -throw "Octopus Server requires .NET 4.5.2. Please install it before attempting to install Octopus Server."
                }

                It 'Throws an exception if .net 4.5.2 or above is not installed (only .net 4.5.0 installed)' {
                    Mock Test-OctopusVersionRequiresDotNet472 { return $false } # older version (pre 2019.7.0)
                    Mock Invoke-MsiExec {}
                    Mock Get-LogDirectory {}
                    Mock Request-File {}
                    Mock Get-RegistryValue { return "378389" } # .NET Framework 4.5
                    Mock Update-InstallState
                    $desiredConfiguration = Get-DesiredConfiguration
                    { Set-TargetResource @desiredConfiguration } | Should -throw "Octopus Server requires .NET 4.5.2. Please install it before attempting to install Octopus Server."
                }

                It 'Throws an exception if .net 4.7.2 or above is not installed (no .net reg key found)' {
                    Mock Test-OctopusVersionRequiresDotNet472 { return $true }
                    Mock Invoke-MsiExec {}
                    Mock Get-LogDirectory {}
                    Mock Request-File {}
                    Mock Get-RegistryValue { return "" }
                    Mock Update-InstallState
                    $desiredConfiguration = Get-DesiredConfiguration
                    { Set-TargetResource @desiredConfiguration } | Should -throw "Octopus Server requires .NET 4.7.2. Please install it before attempting to install Octopus Server."
                }

                It 'Throws an exception if .net 4.7.2 or above is not installed (only .net 4.6.2 installed)' {
                    Mock Test-OctopusVersionRequiresDotNet472 { return $true }
                    Mock Invoke-MsiExec {}
                    Mock Get-LogDirectory {}
                    Mock Request-File {}
                    Mock Get-RegistryValue { return "394802" } # .NET Framework 4.6.2 on Windows Server 2016
                    Mock Update-InstallState
                    $desiredConfiguration = Get-DesiredConfiguration
                    { Set-TargetResource @desiredConfiguration } | Should -throw "Octopus Server requires .NET 4.7.2. Please install it before attempting to install Octopus Server."
                }
            }

            Context "Octopus server command line" {
                BeforeAll {
                    function Get-CurrentConfiguration ([string] $testName) {
                        & (Resolve-Path "$PSCommandPath/../../Tests/OctopusServerExeInvocationFiles/$testName/CurrentState.ps1")
                    }

                    function Get-RequestedConfiguration ([string] $testName) {
                        & (Resolve-Path "$PSCommandPath/../../Tests/OctopusServerExeInvocationFiles/$testName/RequestedState.ps1")
                    }

                    function Get-TempFolder {
                        if ("$($env:TmpDir)" -ne "") {
                            return $env:TmpDir
                        } else {
                            return $env:Temp
                        }
                    }
                }

                function ConvertTo-Hashtable
                {
                    param (
                        [Parameter(ValueFromPipeline = $true)]
                        [Object[]] $InputObject
                    )

                    process {
                        foreach ($object in $InputObject) {
                            $hash = @{}
                            foreach ($property in $object.PSObject.Properties) {
                                $hash[$property.Name] = $property.Value
                            }
                            $hash
                        }
                    }
                }

                function Assert-ExpectedResult ([string] $testName) {
                    # todo: test order of execution here
                    $invocations = & (Resolve-Path "$PSCommandPath/../../Tests/OctopusServerExeInvocationFiles/$testName/ExpectedResult.ps1")
                    $name = @{label="line";expression={$_}};
                    $cases = @($invocations | select-object -Property $name) | ConvertTo-HashTable
                    it "Should call octopus.server.exe $($invocations.count) times" {
                        Assert-MockCalled -CommandName 'Invoke-OctopusServerCommand' -Times $invocations.Count -Exactly
                    }
                    if ($cases.length -gt 0) {
                        it "Should call octopus.server.exe with args '<line>'" -TestCases $cases {
                            param($line)
                            write-verbose "Checking line $line" # workaround ReviewUnusedParameter does not capture parameter usage within a scriptblock.  See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472
                            Set-TargetResource @params
                            Assert-MockCalled -CommandName 'Invoke-OctopusServerCommand' -Times 1 -Exactly -ParameterFilter { ($cmdArgs -join ' ') -eq $line }
                        }
                    }
                }

                Context "New instance" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand {} #{write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "NewInstance" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true } # just assume we're the most recent version
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux

                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "NewInstance"
                    }
                    Assert-ExpectedResult "NewInstance"
                    it "Should download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File
                    }

                    it "Should install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec
                    }
                }

                Context "New instance with metrics" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "NewInstanceWithMetrics" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true } # just assume we're the most recent version
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux
                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "NewInstanceWithMetrics"
                    }
                    Assert-ExpectedResult "NewInstanceWithMetrics"
                    it "Should download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File
                    }
                    it "Should install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec
                    }
                }

                Context "When MasterKey is supplied on new instance" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "MasterKeySupplied" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true } # just assume we're the most recent version
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux
                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "MasterKeySupplied"
                    }
                    Assert-ExpectedResult "MasterKeySupplied"
                    it "Should download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File
                    }
                    it "Should install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec
                    }
                }

                Context "When uninstalling running instance" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{ param ($cmdArgs) write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "UninstallingRunningInstance" }
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Get-ExistingOctopusService { return @() }
                        Mock Get-LogDirectory { return Get-TempFolder }
                        Mock Test-Path -ParameterFilter { $path -eq "$($env:SystemDrive)\Octopus\Octopus-x64.msi" } { return $true }
                        Mock Start-Process { return @{ ExitCode = 0} }
                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "UninstallingRunningInstance"
                    }
                    Assert-ExpectedResult "UninstallingRunningInstance"
                    it "Should not download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File -Times 0 -Exactly
                    }
                    it "Should not try and install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec -Times 0 -Exactly
                    }
                    it "Should uninstall the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Start-Process -Times 1 -Exactly -ParameterFilter { $FilePath -eq "msiexec.exe" -and $ArgumentList -eq "/x $($env:SystemDrive)\Octopus\Octopus-x64.msi /quiet /l*v $(Get-TempFolder)\Octopus-x64.msi.uninstall.log"}
                    }
                }

                Context "Run-on-server user - new install" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{ param ($cmdArgs) write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "NewInstallWithBuiltInWorker" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true }
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux

                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "NewInstallWithBuiltInWorker"
                    }
                    Assert-ExpectedResult "NewInstallWithBuiltInWorker"
                    it "Should download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File
                    }
                    it "Should install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec
                    }
                }

                Context "Run-on-server user - existing install" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{ param ($cmdArgs) write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "EnableBuiltInWorkerOnExistingInstance" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true }
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux

                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "EnableBuiltInWorkerOnExistingInstance"
                    }
                    Assert-ExpectedResult "EnableBuiltInWorkerOnExistingInstance"
                    it "Should not download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File -Times 0 -Exactly
                    }
                    it "Should not try and install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec -Times 0 -Exactly
                    }
                }

                Context "Upgrade" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{ param ($cmdArgs) write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "UpgradeExistingInstance" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true }
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux

                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "UpgradeExistingInstance"
                    }
                    Assert-ExpectedResult "UpgradeExistingInstance"
                    it "Should download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File
                    }
                    it "Should install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec
                    }
                }

                Context "Change WebListenPrefix" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{ param ($cmdArgs) write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "ChangeWebListenPrefix" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true }
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux

                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "ChangeWebListenPrefix"
                    }
                    Assert-ExpectedResult "ChangeWebListenPrefix"
                    it "Should not download the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Request-File -Times 0 -Exactly
                    }
                    it "Should not try and install the MSI" {
                        Set-TargetResource @params
                        Assert-MockCalled Invoke-MsiExec -Times 0 -Exactly
                    }
                }

                Context "When nothing changes" {
                    BeforeAll {
                        Mock Invoke-OctopusServerCommand #{ param ($cmdArgs) write-host $cmdArgs}
                        Mock Get-TargetResource { return Get-CurrentConfiguration "WhenNothingChanges" }
                        Mock Get-RegistryValue { return "478389" } # checking .net 4.5
                        Mock Invoke-MsiExec {}
                        Mock Get-LogDirectory {}
                        Mock Request-File {}
                        Mock Update-InstallState {}
                        Mock Test-OctopusDeployServerResponding { return $true }
                        Mock Test-OctopusVersionNewerThan { return $true }
                        Mock ConvertFrom-SecureString { return "" } # mock this, as its not available on mac/linux
                        Mock Stop-OctopusDeployService

                        [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                        $params = Get-RequestedConfiguration "WhenNothingChanges"
                    }
                    Assert-ExpectedResult "WhenNothingChanges"
                    it "Should not restart the service" {
                        Set-TargetResource @params
                        Assert-MockCalled Stop-OctopusDeployService -Times 0 -Exactly
                    }
                }
            }
        }
    }
}
finally
{
    if ($module) {
        Remove-Module -ModuleInfo $module
    }
}
