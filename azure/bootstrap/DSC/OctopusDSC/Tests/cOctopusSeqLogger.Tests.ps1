#requires -Version 4.0
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

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
            $sampleConfigPath = Split-Path $PSCommandPath -Parent
            $sampleConfigPath = Join-Path $sampleConfigPath "SampleConfigs"
        }

        Describe 'cOctopusSeqLogger' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $password = ConvertTo-SecureString "S3cur3P4ssphraseHere!" -AsPlainText -Force
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $apiKey = New-Object System.Management.Automation.PSCredential ("ignored", $password)
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     InstanceType           = 'OctopusServer'
                     Ensure                 = 'Present'
                     SeqServer              = 'https://seq.example.com'
                     SeqApiKey              = $apiKey
                     Properties             = @{ Application = "Octopus"; Server = "MyServer" }
                }
            }

            Context 'Get-TargetResource' {
                It 'Returns expected data for valid config' {
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Test-NLogDll { return $true }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }

                    $config = Get-TargetResourceInternal @desiredConfiguration
                    $config.ConfigVersion                             | Should -Be 2
                    $config.InstanceType                              | Should -Be 'OctopusServer'
                    $config.Ensure                                    | Should -Be 'Present'
                    $config.SeqServer                                 | Should -Be 'https://seq.example.com'
                    $config.SeqApiKey.GetNetworkCredential().Password | Should -Be '1a2b3c4d5e6f'
                    $config.Properties['Application']                 | Should -Be $desiredConfiguration.Properties['Application']
                    $config.Properties['Server']                      | Should -Be $desiredConfiguration.Properties['Server']
                }

                It 'Returns expected data for old sync config' {
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Test-NLogDll { return $true }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-old-sync-configuration-with-api-key.xml")) }

                    $config = Get-TargetResourceInternal @desiredConfiguration
                    $config.ConfigVersion                             | Should -Be 1
                    $config.InstanceType                              | Should -Be 'OctopusServer'
                    $config.Ensure                                    | Should -Be 'Present'
                    $config.SeqServer                                 | Should -Be 'https://seq.example.com'
                    $config.SeqApiKey.GetNetworkCredential().Password | Should -Be '1a2b3c4d5e6f'
                    $config.Properties['Application']                 | Should -Be $desiredConfiguration.Properties['Application']
                    $config.Properties['Server']                      | Should -Be $desiredConfiguration.Properties['Server']
                }

                It 'Returns expected data when config not set' {
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Test-NLogDll { return $true }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-when-not-configured.xml")) }

                    $config = Get-TargetResourceInternal @desiredConfiguration
                    $config.InstanceType     | Should -Be 'OctopusServer'
                    $config.Ensure           | Should -Be 'Absent'
                    $config.SeqServer        | Should -Be $null
                    $config.SeqApiKey        | Should -Be $null
                    $config.Properties.Count | Should -Be 0
                }

                It 'Returns expected data when dll does not exist' {
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Test-NLogDll { return $false }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }

                    $config = Get-TargetResourceInternal @desiredConfiguration
                    $config.InstanceType                              | Should -Be 'OctopusServer'
                    $config.Ensure                                    | Should -Be 'Absent'
                    $config.SeqServer                                 | Should -Be 'https://seq.example.com'
                    $config.SeqApiKey.GetNetworkCredential().Password | Should -Be '1a2b3c4d5e6f'
                    $config.Properties['Application']                 | Should -Be $desiredConfiguration.Properties['Application']
                    $config.Properties['Server']                      | Should -Be $desiredConfiguration.Properties['Server']
                }

                It 'Throws an exception if Octopus is not installed and ensure is set to present' {
                    Mock Test-Path { return $false } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-Path { return $false } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Test-NLogDll { return $true }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }
                    { Get-TargetResourceInternal @desiredConfiguration } | Should -throw "Unable to find Octopus (checked for existence of file '$octopusServerExePath')."
                }

                It 'Does not throw an exception if Octopus is not installed and ensure is set to absent' {
                    Mock Test-Path { return $false } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-Path { return $false } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Test-NLogDll { return $true }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }
                    $desiredConfiguration.Ensure = 'Absent'
                    { Get-TargetResourceInternal @desiredConfiguration } | Should -not -throw "Unable to find Octopus (checked for existence of file '$octopusServerExePath')."
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ InstanceType="OctopusServer"; Ensure='Present' }
                    Mock Get-TargetResourceInternal { return $response }
                }

                It 'Returns True when its got the expected values' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $true
                }

                It 'Returns false when there are a different number of properties' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyServer"; AnotherProperty = "PropertyValue" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when there the properties have different names' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; AnotherProperty = "MyServer" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when there the properties have different values' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyDifferemtServer" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when the api key is different' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "abcd1234" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when the server is different' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq2.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

               It 'Returns false when its currently disabled and installation requested' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Absent'
                    $response['SeqServer'] = $null
                    $response['SeqApiKey'] = $null
                    $response['Properties'] = @{ }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

               It 'Returns false when its currently enabled and removal requested' {
                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Absent'
                    $desiredConfiguration['SeqServer'] = $null
                    $desiredConfiguration['SeqApiKey'] = $null
                    $desiredConfiguration['Properties'] = @{ }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }

                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    Test-TargetResourceInternal @desiredConfiguration
                    Assert-MockCalled Get-TargetResourceInternal
                }

                It 'returns false when its got the old config' {
                    $desiredPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $desiredApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $desiredPassword)

                    $desiredConfiguration['InstanceType'] = 'OctopusServer'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['SeqServer'] = 'https://seq.example.com'
                    $desiredConfiguration['SeqApiKey'] = $desiredApiKey
                    $desiredConfiguration['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }

                    $actualPassword = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $actualApiKey = New-Object System.Management.Automation.PSCredential ("ignored", $actualPassword)

                    $response['InstanceType'] = 'OctopusServer'
                    $response['Ensure'] = 'Present'
                    $response['SeqServer'] = 'https://seq.example.com'
                    $response['SeqApiKey'] = $actualApiKey
                    $response['Properties'] = @{ Application = "Octopus"; Server = "MyServer" }
                    $response['ConfifVersion'] = 1

                    Test-TargetResourceInternal @desiredConfiguration | Should -Be $false
                }
            }

            Context 'Set-TargetResource' {
                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    $response = @{ InstanceType="OctopusServer"; Ensure='Present'; SeqServer = 'https://seq.example.com' }
                    Mock Get-TargetResourceInternal { return $response }
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }
                    Mock Request-SeqClientNlogDll
                    Mock Save-NlogConfig
                    Set-TargetResourceInternal @desiredConfiguration
                    Assert-MockCalled Get-TargetResourceInternal
                }

                It 'Deletes the dll if it exists and ensure is set to absent' {
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Mock Test-Path { return $false } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Remove-Item
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' -Ensure 'Absent'
                    Assert-MockCalled Remove-Item -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                }

                It 'Removes the settings from the nlog config file if ensure is set to absent' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is NOT installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    # the nlog config file does exist
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }
                    $expected = [xml](Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-when-not-configured.xml"))

                    Mock Save-NlogConfig { $nlogConfig.OuterXml | Should -Be $expected.OuterXml }

                    #call the internal one, as we cant figure out how to mock the ciminstance
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' -Ensure 'Absent'

                    Assert-MockCalled Save-NlogConfig
                }

                It 'Removes the settings from the nlog config file if ensure is set to absent when config is the old sync version' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is NOT installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    # the nlog config file does exist
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe.nlog" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-old-sync-configuration-with-api-key.xml")) }
                    $expected = [xml](Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-when-not-configured.xml"))

                    Mock Save-NlogConfig { $nlogConfig.OuterXml | Should -Be $expected.OuterXml }

                    #call the internal one, as we cant figure out how to mock the ciminstance
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' -Ensure 'Absent'

                    Assert-MockCalled Save-NlogConfig
                }

                It 'Downloads the dll if it doesnt exist and ensure is set to present' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is NOT installed
                    Mock Test-Path { return $false } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml")) }
                    Mock Request-SeqClientNlogDll
                    Mock Save-NlogConfig
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $apiKey = New-Object System.Management.Automation.PSCredential ("ignored", $password)
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' -Ensure 'Present' -SeqServer "https://seq.example.com" -SeqApiKey $apiKey
                    Assert-MockCalled Request-SeqClientNlogDll -ParameterFilter { $dllPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Assert-MockCalled Save-NlogConfig
                }

                It 'Add the settings to the nlog config file if ensure is set to present with no api key' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is NOT installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-when-not-configured.xml")) }
                    $expected = [xml](Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration.xml"))

                    Mock Save-NlogConfig { $nlogConfig.OuterXml | Should -Be $expected.OuterXml }

                    #call the internal one, as we cant figure out how to mock the ciminstance
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' `
                                       -Ensure 'Present' `
                                       -SeqServer "https://seq.example.com" `
                                       -Properties @{ Application = "Octopus"; Server="MyServer" }

                    Assert-MockCalled Save-NlogConfig
                }

                It 'Add the settings to the nlog config file if ensure is set to present with an api key' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-when-not-configured.xml")) }
                    $expected = [xml](Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml"))

                    Mock Save-NlogConfig { $nlogConfig.OuterXml | Should -Be $expected.OuterXml }
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $apiKey = New-Object System.Management.Automation.PSCredential ("ignored", $password)

                    #call the internal one, as we cant figure out how to mock the ciminstance
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' `
                                       -Ensure 'Present' `
                                       -SeqServer "https://seq.example.com" `
                                       -SeqApiKey $apiKey `
                                       -Properties @{ Application = "Octopus"; Server="MyServer" }

                    Assert-MockCalled Save-NlogConfig
                }

                It 'Updates the settings in the nlog config file if config is version 1' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Mock Get-NLogConfig { return  [xml] (Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-old-sync-configuration-with-api-key.xml")) }
                    $expected = [xml](Get-Content (Join-Path $sampleConfigPath "octopus.server.exe.nlog-with-valid-configuration-with-api-key.xml"))

                    Mock Save-NlogConfig { $nlogConfig.OuterXml | Should -Be $expected.OuterXml }
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $apiKey = New-Object System.Management.Automation.PSCredential ("ignored", $password)

                    #call the internal one, as we cant figure out how to mock the ciminstance
                    Set-TargetResourceInternal -InstanceType 'OctopusServer' `
                                       -Ensure 'Present' `
                                       -SeqServer "https://seq.example.com" `
                                       -SeqApiKey $apiKey `
                                       -Properties @{ Application = "Octopus"; Server="MyServer" }

                    Assert-MockCalled Save-NlogConfig
                }

                It 'Throws if ensure is set to present and SeqServer is not supplied' {
                    #octopus is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    # the nlog dll is installed
                    Mock Test-Path { return $true } -ParameterFilter { $Path -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Seq.Client.NLog.dll" }
                    Mock Save-NlogConfig

                    #call the internal one, as we cant figure out how to mock the ciminstance
                    { Set-TargetResourceInternal -InstanceType 'OctopusServer' -Ensure 'Present' } | Should -throw "Property 'SeqServer' should be supplied if 'Ensure' is set to 'Present'"
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
