#requires -Version 4.0

$moduleName = Split-Path ($PSCommandPath -replace '\.Tests\.ps1$', '') -Leaf
$modulePath = Split-Path $PSCommandPath -Parent
$modulePath = Resolve-Path "$PSCommandPath/../../DSCResources/$moduleName/$moduleName.psm1"
$module = $null

try
{
    $prefix = [guid]::NewGuid().Guid -replace '-'
    $module = Import-Module $modulePath -Prefix $prefix -PassThru -ErrorAction Stop

    InModuleScope $module.Name {

        BeforeAll {
            # Get-Service is not available on mac/unix systems - fake it
            $getServiceCommand = Get-Command "Get-Service" -ErrorAction SilentlyContinue
            if ($null -eq $getServiceCommand) {
                function Get-Service {
                    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidOverwritingBuiltInCmdlets', '', Justification='Get-Service is not available on mac/unix systems, so without faking it, our builds fail')]
                    param()
                }
            }
        }

        Describe 'cTentacleAgent' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     Name                   = 'Stub'
                     Ensure                 = 'Present'
                     State                  = 'Started'
                }
            }

            Context 'Test-ParameterSet' {
                It 'Throws if PublicHostNameConfiguration is Custom but CustomPublicHostName not set' {
                    { Test-ParameterSet -publicHostNameConfiguration "Custom" -CustomPublicHostName $null -WorkerPools @() -Environments @('My Env') -Roles @() -Tenants @() -TenantTags @() } `
                        | Should -throw "Invalid configuration requested. PublicHostNameConfiguration was set to 'Custom' but an invalid or null CustomPublicHostName was specified."
                }
                It 'Throws if WorkerPools are provided and Environments are provided' {
                    { Test-ParameterSet -publicHostNameConfiguration "PublicIp" -CustomPublicHostName $null -WorkerPools @('My Worker Pool') -Environments @('My Env') -Roles @() -Tenants @() -TenantTags @() } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be registered as a worker, but still provided the 'Environments' configuration argument. Please remove the 'Environments' configuration argument."
                }
                It 'Throws if WorkerPools are provided and Roles are provided' {
                    { Test-ParameterSet -publicHostNameConfiguration "PublicIp" -CustomPublicHostName $null -WorkerPools @('My Worker Pool') -Environments @() -Roles @('My Roles') -Tenants @() -TenantTags @() } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be registered as a worker, but still provided the 'Roles' configuration argument. Please remove the 'Roles' configuration argument."
                }
                It 'Throws if WorkerPools are provided and Tenants are provided' {
                    { Test-ParameterSet -publicHostNameConfiguration "PublicIp" -CustomPublicHostName $null -WorkerPools @('My Worker Pool') -Environments @() -Roles @() -Tenants @('Jim-Bob') -TenantTags @() } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be registered as a worker, but still provided the 'Tenants' configuration argument. Please remove the 'Tenants' configuration argument."
                }
                It 'Throws if WorkerPools are provided and Tenant Tags are provided' {
                    { Test-ParameterSet -publicHostNameConfiguration "PublicIp" -CustomPublicHostName $null -WorkerPools @('My Worker Pool') -Environments @() -Roles @() -Tenants @() -TenantTags @('CustomerType/VIP') } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be registered as a worker, but still provided the 'TenantTags' configuration argument. Please remove the 'TenantTags' configuration argument."
                }
            }

            Context 'Confirm-RegistrationParameter' {
                It 'Throws if RegisterWithServer is false but environment provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Environments @('My Env') } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle not to be registered with the server, but still provided the 'Environments' configuration argument. Please remove the 'Environments' configuration argument or set 'RegisterWithServer = `$True'."
                }
                It 'Throws if RegisterWithServer is false but roles provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Roles @('app-server') } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle not to be registered with the server, but still provided the 'Roles' configuration argument. Please remove the 'Roles' configuration argument or set 'RegisterWithServer = `$True'."
                }
                It 'Throws if RegisterWithServer is false but tenants provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Tenants @('Jim-Bob') } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle not to be registered with the server, but still provided the 'Tenants' configuration argument. Please remove the 'Tenants' configuration argument or set 'RegisterWithServer = `$True'."
                }
                It 'Throws if RegisterWithServer is false but tenant Tags provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -TenantTags @('CustomerType/VIP', 'Hosting/OnPrem') } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle not to be registered with the server, but still provided the 'TenantTags' configuration argument. Please remove the 'TenantTags' configuration argument or set 'RegisterWithServer = `$True'."
                }
                It 'Throws if RegisterWithServer is false but policy provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Policy "my policy" } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle not to be registered with the server, but still provided the 'Policy' configuration argument. Please remove the 'Policy' configuration argument or set 'RegisterWithServer = `$True'."
                }
                It 'Throws if RegisterWithServer is true but no OctopusServerUrl provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $true -OctopusServerUrl $null } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be registered with the server, but not provided the 'OctopusServerUrl' configuration argument. Please specify the 'OctopusServerUrl' configuration argument or set 'RegisterWithServer = `$False'."
                }
                It 'Throws if RegisterWithServer is true but no ApiKey provided' {
                    { Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $true -OctopusServerUrl "https://example.octopus.com" -ApiKey $null } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be registered with the server, but not provided the 'ApiKey' configuration argument. Please specify the 'ApiKey' configuration argument or set 'RegisterWithServer = `$False'."
                }
                It 'Does not throw if RegisterWithServer is false and environment provided as empty string' {
                    Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Environments ""
                }
                It 'Does not throw if RegisterWithServer is false and environment provided as empty array' {
                    Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Environments @()
                }
                It 'Does not throw if RegisterWithServer is false and environment provided as array with empty element' {
                    Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False -Environments @('')
                }
                It 'Does not throw if RegisterWithServer is false and no environment provided' {
                    Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $False
                }
                It 'Does not throw if RegisterWithServer is true and OctopusServerUrl and ApiKey provided' {
                    Confirm-RegistrationParameter -Ensure "Present" -RegisterWithServer $true -OctopusServerUrl "https://example.octopus.com" -ApiKey "API-1234"
                }
                It 'Throws if Ensure = absent, RegisterWithServer is true and no ApiKey provided' {
                    { Confirm-RegistrationParameter -Ensure "Absent" -RegisterWithServer $true -OctopusServerUrl "https://example.octopus.com" -ApiKey $null } `
                        | Should -throw "Invalid configuration requested. You have asked for the Tentacle to be de-registered from the server, but not provided the 'ApiKey' configuration argument. Please specify the 'ApiKey' configuration argument or set 'RegisterWithServer = `$False'."
                }
            }

            Context 'Confirm-RequestedState' {
                It 'Throws if Ensure is absent but state is started' {
                    { Confirm-RequestedState @{"Ensure" = "Absent"; "State" = "Started";} } `
                    | Should -throw "Invalid configuration requested. You have asked for the service to not exist, but also be running at the same time. You probably want 'State = `"Stopped`"'."
                }
                It 'Does not throws if Ensure is absent but state not provided' {
                    { Confirm-RequestedState @{"Ensure" = "Absent";} } `
                        | Should -not -throw "foo"
                }
            }

            Context 'Get-WorkerPoolMembership' {
                It 'always returns an array, even if only one item returned' {
                    Mock Get-APIResult { return @( [pscustomobject] @{ Name = "Pool1"; Id = "WorkerPools-1" } )} -ParameterFilter {$api -eq "/workerpools/all"}
                    Mock Get-APIResult { return @( [pscustomobject] @{ Name = "Worker1"; WorkerPoolIds = @("WorkerPools-1"); Thumbprint = "12345678"} )} -ParameterFilter {$api -eq "/workers/all"}
                    $result = Get-WorkerPoolMembership -ServerUrl "https://example.com" -Thumbprint "12345678" -ApiKey "API-1234" -SpaceId $null
                    $result.Count | Should -Not -Be $null
                }
            }

            Context 'Get-WorkerPoolMembership' {
                It 'always returns an array, even if only one item returned' {
                    Mock Get-APIResult { return @( [pscustomobject] @{ Name = "Pool1"; Id = "WorkerPools-1" } )} -ParameterFilter {$api -eq "/workerpools/all"}
                    Mock Get-APIResult { return @( [pscustomobject] @{ Name = "Worker1"; WorkerPoolIds = @("WorkerPools-1"); Thumbprint = "12345678"} )} -ParameterFilter {$api -eq "/workers/all"}
                    $result = Get-WorkerPoolMembership -ServerUrl "http://localhost:8065" -Thumbprint "D80D5A3DF457E1EFB355451109588DBE26F59368" -ApiKey "API-JM91EXRDGJTCTT7SEEVMJ7E73R4" -SpaceId $null
                    $result.GetType() | Should -Be "System.Object[]"
                    $result.Count | Should -Not -Be $null
                }
            }

            Context 'Get-TargetResource' {
                BeforeAll {
                    Mock Get-ItemProperty { return @{ InstallLocation = "c:\Octopus\Tentacle\Stub" }}
                    Mock Get-Service { return @{ Status = "Running" }}
                }

                It 'Returns the proper data' {
                    $config = Get-TargetResource -Name 'Stub' -PublicHostNameConfiguration "PublicIp"
                    $config.GetType()                  | Should -Be ([hashtable])
                    $config['Name']                    | Should -Be 'Stub'
                    $config['Ensure']                  | Should -Be 'Present'
                    $config['State']                   | Should -Be 'Started'
                }

                It "Throws if we specify a null or invalid CustomHostName" {
                    { Get-TargetResource -Name "Stub" -PublicHostNameConfiguration "Custom" -CustomPublicHostName $null } `
                        | Should -throw "Invalid configuration requested. PublicHostNameConfiguration was set to 'Custom' but an invalid or null CustomPublicHostName was specified."
                    { Get-TargetResource -Name "Stub" -PublicHostNameConfiguration "Custom" -CustomPublicHostName "  " } `
                        | Should -throw "Invalid configuration requested. PublicHostNameConfiguration was set to 'Custom' but an invalid or null CustomPublicHostName was specified."
                    { Get-TargetResource -Name "Stub" -PublicHostNameConfiguration "Custom" -CustomPublicHostName "mydnsname" } `
                        | Should -not -throw
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ Ensure="Absent"; State="Stopped" }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns True when Ensure is set to Absent and Tentacle does not exist' {
                    $desiredConfiguration['Ensure'] = 'Absent'
                    $desiredConfiguration['State'] = 'Stopped'
                    $response['Ensure'] = 'Absent'
                    $response['State'] = 'Stopped'
                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

               It 'Returns True when Ensure is set to Present and Tentacle exists' {
                    $desiredConfiguration = @{
                        Ensure = 'Present'
                        State = 'Started'
                        OctopusServerUrl = 'http://fakeserver1'
                        APIKey = 'API-GRKUQFCFIJM7G2RJM3VMRW43SK'
                        Name = 'Tentacle1'
                        Environments = @()
                        Roles = @()
                        WorkerPools = @()
                        Space = "Default"
                    }
                    $response['Ensure'] = 'Present'
                    $response['State'] = 'Started'
                    # Declare mock objects
                    $mockMachine = @{
                        Name = "MockMachine"
                        EnvironmentIds = @()
                        WorkerPools = @()
                        Roles = @()
                    }
                    # Declare mock calls
                    Mock Get-MachineFromOctopusServer {return $mockMachine}
                    Mock Get-APIResult {return [string]::Empty}
                    Mock Get-TentacleThumbprint { return "ABCDE123456" }
                    Mock Get-Space { return @{
                        "Id" = "Spaces-1"
                    }}
                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Throws an error when space does not exist' {
                    $desiredConfiguration = @{
                        Ensure = 'Present'
                        State = 'Started'
                        OctopusServerUrl = 'http://fakeserver1'
                        APIKey = 'API-GRKUQFCFIJM7G2RJM3VMRW43SK'
                        Name = 'Tentacle1'
                        Environments = @()
                        Roles = @()
                        WorkerPools = @()
                        Space = "NonExistentSpace"
                    }
                    $response['Ensure'] = 'Present'
                    $response['State'] = 'Started'
                    # Declare mock objects
                    $mockMachine = @{
                        Name = "MockMachine"
                        EnvironmentIds = @()
                        WorkerPools = @()
                        Roles = @()
                    }
                    # Declare mock calls
                    Mock Get-MachineFromOctopusServer {return $mockMachine}
                    Mock Get-APIResult {return [string]::Empty}
                    Mock Get-TentacleThumbprint { return "ABCDE123456" }
                    Mock Get-Space { return $null}
                    { Test-TargetResource @desiredConfiguration } | Should -Throw -ExpectedMessage "Unable to find a space by the name of 'NonExistentSpace'"
                }

                It 'Returns true when space exists' {
                    $desiredConfiguration = @{
                        Ensure = 'Present'
                        State = 'Started'
                        OctopusServerUrl = 'http://fakeserver1'
                        APIKey = 'API-GRKUQFCFIJM7G2RJM3VMRW43SK'
                        Name = 'Tentacle1'
                        Environments = @()
                        Roles = @()
                        WorkerPools = @()
                        Space = "Default"
                    }
                    $response['Ensure'] = 'Present'
                    $response['State'] = 'Started'
                    # Declare mock objects
                    $mockMachine = @{
                        Name = "MockMachine"
                        EnvironmentIds = @()
                        WorkerPools = @()
                        Roles = @()
                    }
                    # Declare mock calls
                    Mock Get-MachineFromOctopusServer {return $mockMachine}
                    Mock Get-APIResult {return [string]::Empty}
                    Mock Get-TentacleThumbprint { return "ABCDE123456" }
                    Mock Get-Space { return "Spaces-1"}
                    { Test-TargetResource @desiredConfiguration } | Should -Be $true
                }
            }

            Context 'Set-TargetResource' {
                #todo: more tests
                Mock Invoke-AndAssert { return $true }
                Mock Install-Tentacle { return $true }
            }
        }

        Describe "Testing Get-MyPublicIPAddress" {
            BeforeAll {
                $testIP = "54.121.34.56"
                Mock Invoke-RestMethod { return $testIP }
            }

            Context "First option works" {
                It "Should return an IPv4 address" {
                    Get-MyPublicIPAddress | Should -Be $testIP
                }
            }

            Context "First option is down" {
                It "Should return an IPv4 address" {
                    Mock Invoke-RestMethod { throw } -ParameterFilter { $uri -eq "https://api.ipify.org/"}
                    Get-MyPublicIPAddress | Should -Be $testIP
                }
            }

            Context "First and Second Options are down" {
                It "Should return an IPv4 address" {
                    Mock Invoke-RestMethod { throw } -ParameterFilter { $uri -eq "https://api.ipify.org/" -or $uri -eq 'https://canhazip.com/'}
                    Get-MyPublicIPAddress | Should -Be $testIP
                }
            }

            Context "All three are down, Should -throw" {
                It "Should throw" {
                    Mock Invoke-RestMethod { throw }
                    { Get-MyPublicIPAddress } | Should -throw "Unable to determine your Public IP address. Please supply a hostname or IP address via the PublicHostName parameter."
                }
            }

            Context "A service returns an invalid IP" {
                It "Should throw" {
                    Mock Invoke-RestMethod { return "IAMNOTANIPADDRESS" }
                    { Get-MyPublicIpAddress } | Should -throw "Detected Public IP address 'IAMNOTANIPADDRESS', but we we couldn't parse it as an IPv4 address."
                }
            }
        }

        Context "Tentacle command line" {
            BeforeAll {
                function Get-CurrentConfiguration ([string] $testName) {
                    & (Resolve-Path "$PSCommandPath/../../Tests/TentacleExeInvocationFiles/$testName/CurrentState.ps1")
                }

                function Get-RequestedConfiguration ([string] $testName) {
                    & (Resolve-Path "$PSCommandPath/../../Tests/TentacleExeInvocationFiles/$testName/RequestedState.ps1")
                }

                function Get-TempFolder {
                    if ("$($env:TmpDir)" -ne "") {
                        return $env:TmpDir
                    } else {
                        return $env:Temp
                    }
                }

                # create stubs for these cmdlets on linux/mac as they dont natively exist
                # leading to pester complaining that it cant mock it...
                if (-not $isWindows) {
                    function Start-Service {
                        [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidOverwritingBuiltInCmdlets', '', Justification='not available on mac/unix systems, so without faking it, our builds fail')]
                        param()
                    }
                    function Stop-Service {
                        [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidOverwritingBuiltInCmdlets', '', Justification='not available on mac/unix systems, so without faking it, our builds fail')]
                        param()
                    }
                    function Get-CimInstance {
                        [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidOverwritingBuiltInCmdlets', '', Justification='not available on mac/unix systems, so without faking it, our builds fail')]
                        param()
                    }
                }
            }

            function ConvertTo-Hashtable {
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
                # todo: test order of execution here as well
                $invocations = & (Resolve-Path "$PSCommandPath/../../Tests/TentacleExeInvocationFiles/$testName/ExpectedResult.ps1")
                $name = @{label="line";expression={$_}};
                $cases = @($invocations | select-object -Property $name) | ConvertTo-HashTable

                it "Should call tentacle.exe $($invocations.count) times" {
                    Assert-MockCalled -CommandName 'Invoke-TentacleCommand' -Times $invocations.Count -Exactly
                }
                if ($cases.length -gt 0)
                {
                    it "Should call tentacle.exe with args '<line>'" -TestCases $cases {
                        param($line)
                        write-verbose "Checking line $line" # workaround ReviewUnusedParameter does not capture parameter usage within a scriptblock.  See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472
                        Set-TargetResource @params
                        Assert-MockCalled -CommandName 'Invoke-TentacleCommand' -Times 1 -Exactly -ParameterFilter { ($cmdArgs -join ' ') -eq $line }
                    }
                }
            }

            Context "New instance" {
                BeforeAll {
                    Mock Invoke-TentacleCommand {} -Verifiable #{ write-host "`"$($cmdArgs -join ' ')`"," } -Verifiable
                    Mock Get-TargetResource { return Get-CurrentConfiguration "NewInstance" }
                    Mock Invoke-MsiExec {} -Verifiable
                    Mock Request-File {} -Verifiable
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {} -Verifiable
                    Mock Get-PublicHostName { return "mytestserver.local"; }
                    Mock New-Item {}
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
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
            }

            Context "New polling tentacle" {
                BeforeAll {
                    Mock Invoke-TentacleCommand {} #{ write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "NewPollingTentacle" }
                    Mock Invoke-MsiExec { }
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Get-PublicHostName { return "mytestserver.local"; }
                    Mock New-Item {}
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "NewPollingTentacle"
                }
                Assert-ExpectedResult "NewPollingTentacle"
                it "Should download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File
                }
                it "Should install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec
                }
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
            }

            Context "New instance in space" {
                BeforeAll {
                    Mock Invoke-TentacleCommand #{ write-host "`"$(cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "NewInstanceInSpace" }
                    Mock Invoke-MsiExec {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Get-PublicHostName { return "mytestserver.local"; }
                    Mock New-Item {}
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "NewInstanceInSpace"
                }
                Assert-ExpectedResult "NewInstanceInSpace"
                it "Should download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File
                }
                it "Should install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec
                }
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
            }

            Context "New Worker" {
                BeforeAll {
                    Mock Invoke-TentacleCommand # { write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "NewWorker" }
                    Mock Invoke-MsiExec {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Get-PublicHostName { return "mytestserver.local"; }
                    Mock New-Item {}
                    Mock Test-TentacleExecutableExists { return $true }
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "NewWorker"
                }
                Assert-ExpectedResult "NewWorker"

                it "Should download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File
                }
                it "Should install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec
                }
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
            }

            Context "New Worker in space" {
                BeforeAll {
                    Mock Invoke-TentacleCommand #{ write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "NewWorkerInSpace" }
                    Mock Invoke-MsiExec {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Get-PublicHostName { return "mytestserver.local"; }
                    Mock New-Item {}
                    Mock Test-TentacleExecutableExists { return $true }
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "NewWorkerInSpace"
                }
                Assert-ExpectedResult "NewWorkerInSpace"
                it "Should download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File
                }
                it "Should install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec
                }
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
            }

            Context "Install only" {
                BeforeAll {
                    Mock Invoke-TentacleCommand #{ write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "InstallOnly" }
                    Mock Invoke-MsiExec {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock New-Item {}
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "InstallOnly"
                }
                Assert-ExpectedResult "InstallOnly"
                it "Should download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File
                }
                it "Should install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec
                }
                it "Should start not the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service -times 0
                }
            }

            Context "Uninstall running instance" {
                BeforeAll {
                    Mock Invoke-TentacleCommand # { write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "UninstallingRunningInstance" }
                    Mock Invoke-MsiExec {}
                    Mock Invoke-MsiUninstall {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Get-CimInstance { return @() } # no other instances on the box
                    Mock Test-TentacleExecutableExists { return $true }
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "UninstallingRunningInstance"
                }
                Assert-ExpectedResult "UninstallingRunningInstance"
                it "Should not download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File -times 0
                }
                it "Should not install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec -times 0
                }
                it "Should uninstall the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiUninstall
                }
                it "Should not start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service -times 0
                }
            }

            Context "Uninstall running instance (with space)" {
                BeforeAll {
                    Mock Invoke-TentacleCommand #{ write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "UninstallingRunningInstanceInSpace" }
                    Mock Invoke-MsiExec {}
                    Mock Invoke-MsiUninstall {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Get-CimInstance { return @() } # no other instances on the box
                    Mock Test-TentacleExecutableExists { return $true }
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "UninstallingRunningInstanceInSpace"
                }
                Assert-ExpectedResult "UninstallingRunningInstanceInSpace"
                it "Should not download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File -times 0
                }
                it "Should not install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec -times 0
                }
                it "Should uninstall the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiUninstall
                }
                it "Should not start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service -times 0
                }
            }

            Context "Upgrade existing instance" {
                BeforeAll {
                    Mock Invoke-TentacleCommand {} #{ write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "UpgradeExistingInstance" }
                    Mock Invoke-MsiExec {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Stop-Service {}
                    Mock New-Item {}
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
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
                it "Should stop the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Stop-Service
                }
            }

            Context "Upgrade existing instance in space" {
                BeforeAll {
                    Mock Invoke-TentacleCommand #{ write-host "`"$($cmdArgs -join ' ')`"," }
                    Mock Get-TargetResource { return Get-CurrentConfiguration "UpgradeExistingInstanceInSpace" }
                    Mock Invoke-MsiExec {}
                    Mock Request-File {}
                    Mock Update-InstallState {}
                    Mock Invoke-AndAssert {}
                    Mock Start-Service {}
                    Mock Stop-Service {}
                    Mock New-Item {}
                    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "It is actually used, but pester's scoping is weird")]
                    $params = Get-RequestedConfiguration "UpgradeExistingInstanceInSpace"
                }
                Assert-ExpectedResult "UpgradeExistingInstanceInSpace"
                it "Should download the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Request-File
                }
                it "Should install the MSI" {
                    Set-TargetResource @params
                    Assert-MockCalled Invoke-MsiExec
                }
                it "Should start the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Start-Service
                }
                it "Should stop the service" {
                    Set-TargetResource @params
                    Assert-MockCalled Stop-Service
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
