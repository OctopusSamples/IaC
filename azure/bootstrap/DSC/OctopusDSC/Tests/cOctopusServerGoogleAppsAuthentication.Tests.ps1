#requires -Version 4.0

$moduleName = Split-Path ($PSCommandPath -replace '\.Tests\.ps1$', '') -Leaf
$modulePath = Split-Path $PSCommandPath -Parent
$modulePath = Resolve-Path "$PSCommandPath/../../DSCResources/$moduleName/$moduleName.psm1"
$script:dscHelpersPath = Resolve-Path "$PSCommandPath/../../OctopusDSCHelpers.ps1"
$module = $null

try
{
    $prefix = [guid]::NewGuid().Guid -replace '-'
    $module = Import-Module $modulePath -Prefix $prefix -PassThru -ErrorAction Stop

    InModuleScope $module.Name {

        Describe 'cOctopusServerGoogleAppsAuthentication' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     InstanceName             = 'OctopusServer'
                     Enabled                  = $true
                     ClientID                 = "5743519123-1232358520259-3634528"
                     HostedDomain             = "https://octopus.example.com"
                }
            }

            Context 'Get-TargetResource' {
                It 'Returns the proper data' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsAuthenticationProvider { return $true }
                    Mock Get-ServerConfiguration {
                        return  @{
                            Octopus = @{
                                GoogleApps = @{
                                    IsEnabled = $true;
                                    ClientID = "5743519123-1232358520259-3634528";
                                    HostedDomain = "https://octopus.example.com"
                                }
                            }
                        }
                    }

                    $config = Get-TargetResource @desiredConfiguration
                    $config.InstanceName   | Should -Be 'OctopusServer'
                    $config.Enabled        | Should -Be $true
                    $config.ClientID       | Should -Be "5743519123-1232358520259-3634528"
                    $config.HostedDomain   | Should -Be "https://octopus.example.com"
                }

                It 'Throws an exception if Octopus is not installed' {
                    Mock Test-Path { return $false } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsAuthenticationProvider { return $true }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "Unable to find Octopus (checked for existence of file '$octopusServerExePath')."
                }

                It 'Throws an exception if its an old version of Octopus' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsAuthenticationProvider { return $false }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "This resource only supports Octopus Deploy 3.5.0+."
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ InstanceName="OctopusServer"; Enabled=$true }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns True when values the same' {
                    $response['Enabled'] = $true
                    $response['ClientID'] = "5743519123-1232358520259-3634528"
                    $response['HostedDomain'] = "https://octopus.example.com"

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Returns false when its currently disabled' {
                    $response['Enabled'] = $false
                    $response['ClientID'] = "5743519123-1232358520259-3634528"
                    $response['HostedDomain'] = "https://octopus.example.com"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when ClientID is currently different' {
                    $response['Enabled'] = $true
                    $response['ClientID'] = "111111111-2222222222222-3333333"
                    $response['HostedDomain'] = "https://octopus.example.com"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when the container is currently different' {
                    $response['Enabled'] = $false
                    $response['ClientID'] = "5743519123-1232358520259-3634528"
                    $response['HostedDomain'] = "https://octopusdeploy.example.com"
                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    Test-TargetResource @desiredConfiguration
                    Assert-MockCalled Get-TargetResource
                }
            }

            Context 'Set-TargetResource' {
                BeforeAll {
                    . $dscHelpersPath
                }
                It 'Calls Invoke-OctopusServerCommand with the correct arguments' {
                    Mock Invoke-OctopusServerCommand

                    Set-TargetResource -InstanceName 'SuperOctopus' `
                                       -Enabled $false `
                                       -ClientID "5743519123-1232358520259-3634528" `
                                       -HostedDomain "https://octopus.example.com"
                    Assert-MockCalled Invoke-OctopusServerCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'configure --console --instance SuperOctopus --googleAppsIsEnabled false --googleAppsClientID 5743519123-1232358520259-3634528 --googleAppsHostedDomain https://octopus.example.com'}
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
