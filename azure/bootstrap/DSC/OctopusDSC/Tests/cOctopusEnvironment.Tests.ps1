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
        $sampleConfigPath = Split-Path $PSCommandPath -Parent
        $sampleConfigPath = Join-Path $sampleConfigPath "SampleConfigs"

        Describe 'cOctopusEnvironment' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     Url                = 'https://octopus.example.com'
                     Ensure             = 'Present'
                     EnvironmentName    = 'Production'
                     OctopusCredentials = $creds
                }
            }

            Context 'Get-TargetResource - error scenarios' {
                It 'Throws when both OctopusCredentials and OctopusApiKey are provided' {
                    {Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -EnvironmentName 'Production' `
                                                 -OctopusCredentials $creds `
                                                 -OctopusApiKey $creds } | Should -throw "Please provide either 'OctopusCredentials' or 'OctopusApiKey', not both."
                }

                It 'Throws when neither OctopusCredentials and OctopusApiKey are provided' {
                    {Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -EnvironmentName 'Production'} | Should -throw "Please provide either 'OctopusCredentials' or 'OctopusApiKey'."
                }
            }

            Context 'Get-TargetResource - when present' {
                It 'Returns present when environment exists' {
                    Mock Get-Environment { return [PSCustomObject]@{ Name = 'Production' } }
                    $result = Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -EnvironmentName 'Production' `
                                                 -OctopusCredentials $creds
                    $result.Ensure | Should -Be 'Present'
                }
            }

            Context 'Get-TargetResource - when absent' {
                It 'Returns absent when environment does not exist' {
                    Mock Get-Environment { return $null }
                    $result = Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -EnvironmentName 'Production' `
                                                 -OctopusCredentials $creds
                    $result.Ensure | Should -Be 'Absent'
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{  }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns false if environment does not exist' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['EnvironmentName'] = 'Production'
                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['EnvironmentName'] = $null
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns true if environment does exist' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['EnvironmentName'] = 'Production'
                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['EnvironmentName'] = 'Production'
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    Test-TargetResource @desiredConfiguration
                    Assert-MockCalled Get-TargetResource
                }
            }

            Context 'Set-TargetResource - when present' {
                It 'Calls Remove-Environment if present and ensure set to absent' {
                    Mock Get-Environment { return [PSCustomObject]@{ Name = 'Production' } }
                    Mock New-Environment
                    Mock Remove-Environment
                    $desiredConfiguration['Ensure'] = 'Absent'
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Remove-Environment -Exactly 1
                }
            }

            Context 'Set-TargetResource - when absent' {
                It 'Calls New-Environment if not present and ensure set to present' {
                    Mock Get-Environment { return $null }
                    Mock New-Environment
                    Mock Remove-Environment
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled New-Environment  -Exactly 1
                }
            }

            Context 'Set-TargetResource - general' {
                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    $response = @{ Url = 'https://octopus.example.com'; Ensure='Present'; EnvironmentName = 'Production'; OctopusCredentials = $creds }
                    Mock Get-TargetResource { return $response }
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Get-TargetResource -Exactly 1
                }
            }
        }
    }
}
finally {
    if ($module) {
        Remove-Module -ModuleInfo $module
    }
}
