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

        Describe 'cTentacleWatchdog' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     InstanceName            = 'Tentacle'
                     Enabled                 = $true
                     Interval                = 5
                     Instances               = "*"
                }
            }

            Context 'Get-TargetResource' {
                It 'Returns the proper data' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Tentacle\Tentacle.exe" }
                    Mock Test-TentacleSupportsShowConfiguration { return $true }
                    Mock Get-TentacleConfiguration {
                        return  @{
                            Octopus = @{
                                Watchdog = @{
                                    Enabled = $true;
                                    Interval = 5
                                    Instances = "master"
                                }
                            }
                        }
                    }

                    $config = Get-TargetResource @desiredConfiguration
                    $config.InstanceName    | Should -Be 'Tentacle'
                    $config.Enabled         | Should -Be $true
                    $config.Interval        | Should -Be 5
                    $config.Instances       | Should -Be "master"
                }

                It 'Throws an exception if Octopus is not installed' {
                    Mock Test-Path { return $false } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Tentacle\Tentacle.exe" }
                    Mock Test-TentacleSupportsShowConfiguration { return $true }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "Unable to find Tentacle (checked for existence of file '$($env:ProgramFiles)\Octopus Deploy\Tentacle\Tentacle.exe')."
                }

                It 'Throws an exception if its an old version of Tentacle' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Tentacle\Tentacle.exe" }
                    Mock Test-TentacleSupportsShowConfiguration { return $false }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "This resource only supports Tentacle 3.15.8+."
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ InstanceName="Tentacle"; Enabled=$true }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns True when values the same' {
                    $response['Enabled'] = $true
                    $response['Interval'] = 5
                    $response['Instances'] = "*"
                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Returns false when its currently disabled' {
                    $response['Enabled'] = $false
                    $response['Interval'] = 5
                    $response['Instances'] = "*"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when interval is currently different' {
                    $response['Enabled'] = $true
                    $response['Interval'] = 10
                    $response['Instances'] = "*"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when the Instances is currently different' {
                    $response['Enabled'] = $true
                    $response['Interval'] = 5
                    $response['Instances'] = "master"
                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    Test-TargetResource @desiredConfiguration
                    Assert-MockCalled Get-TargetResource
                }
            }

            Context 'Set-TargetResource' {
                It 'Calls Invoke-TentacleCommand with the correct arguments to enable' {
                    Mock Invoke-TentacleCommand
                    Set-TargetResource -InstanceName 'SuperTentacle' `
                                       -Enabled $true `
                                       -Interval 5 `
                                       -Instances "*"
                    Assert-MockCalled Invoke-TentacleCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'watchdog --create --interval 5 --instances "*"'}
                }

                It 'Calls Invoke-TentacleCommand with the correct arguments to disable' {
                    Mock Invoke-TentacleCommand
                    Set-TargetResource -InstanceName 'SuperTentacle' `
                                       -Enabled $false `
                                       -Interval 5 `
                                       -Instances "*"
                    Assert-MockCalled Invoke-TentacleCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'watchdog --delete' }
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
