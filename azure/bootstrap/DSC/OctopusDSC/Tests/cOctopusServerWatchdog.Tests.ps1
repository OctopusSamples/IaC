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

        Describe 'cOctopusServerWatchdog' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     InstanceName            = 'OctopusServer'
                     Enabled                 = $true
                     Interval                = 5
                     Instances               = "*"
                }
            }

            Context 'Get-TargetResource' {
                It 'Returns the proper data' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsWatchdogInShowConfiguration { return $true }
                    Mock Get-ServerConfiguration {
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
                    $config.InstanceName    | Should -Be 'OctopusServer'
                    $config.Enabled         | Should -Be $true
                    $config.Interval        | Should -Be 5
                    $config.Instances       | Should -Be "master"
                }

                It 'Throws an exception if Octopus is not installed' {
                    Mock Test-Path { return $false } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsWatchdogInShowConfiguration { return $true }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "Unable to find Octopus (checked for existence of file '$octopusServerExePath')."
                }

                It 'Throws an exception if its an old version of Octopus' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsWatchdogInShowConfiguration { return $false }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "This resource only supports Octopus Deploy 3.17.0+."
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ InstanceName="OctopusServer"; Enabled=$true }
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
                It 'Calls Invoke-OctopusServerCommand with the correct arguments to enable' {
                    Mock Invoke-OctopusServerCommand

                    Set-TargetResource -InstanceName 'SuperOctopus' `
                                       -Enabled $true `
                                       -Interval 5 `
                                       -Instances "*"
                    Assert-MockCalled Invoke-OctopusServerCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'watchdog --create --interval 5 --instances "*"'}
                }

                It 'Calls Invoke-OctopusServerCommand with the correct arguments to disable' {
                    Mock Invoke-OctopusServerCommand

                    Set-TargetResource -InstanceName 'SuperOctopus' `
                                       -Enabled $false `
                                       -Interval 5 `
                                       -Instances "*"
                    Assert-MockCalled Invoke-OctopusServerCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'watchdog --delete'}
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
