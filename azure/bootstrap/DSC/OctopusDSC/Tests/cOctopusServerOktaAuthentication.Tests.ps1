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

        Describe 'cOctopusServerOktaAuthentication' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     InstanceName            = 'OctopusServer'
                     Enabled                 = $true
                     Issuer                  = "https://dev-258250.oktapreview.com"
                     ClientID                = "752nx5basdskrsbqansE"
                }
            }

            Context 'Get-TargetResource' {
                It 'Returns the proper data' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsOktaAuthenticationProvider { return $true }
                    Mock Get-ServerConfiguration {
                        return  @{
                            Octopus = @{
                                Okta = @{
                                    IsEnabled = $true;
                                    Issuer = "https://dev-258250.oktapreview.com"
                                    ClientID = "752nx5basdskrsbqansE"
                                }
                            }
                        }
                    }

                    $config = Get-TargetResource @desiredConfiguration
                    $config.InstanceName    | Should -Be 'OctopusServer'
                    $config.Enabled         | Should -Be $true
                    $config.Issuer          | Should -Be "https://dev-258250.oktapreview.com"
                    $config.ClientID        | Should -Be "752nx5basdskrsbqansE"
                }

                It 'Throws an exception if Octopus is not installed' {
                    Mock Test-Path { return $false } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsOktaAuthenticationProvider { return $true }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "Unable to find Octopus (checked for existence of file '$octopusServerExePath')."
                }

                It 'Throws an exception if its an old version of Octopus' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsOktaAuthenticationProvider { return $false }
                    { Get-TargetResource @desiredConfiguration } | Should -throw "This resource only supports Octopus Deploy 3.16.0+."
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{ InstanceName="OctopusServer"; Enabled=$true }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns True when values the same' {
                    $response['Enabled'] = $true
                    $response['Issuer'] = "https://dev-258250.oktapreview.com"
                    $response['ClientID'] = "752nx5basdskrsbqansE"

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Returns false when its currently disabled' {
                    $response['Enabled'] = $false
                    $response['Issuer'] = "https://dev-258250.oktapreview.com"
                    $response['ClientID'] = "752nx5basdskrsbqansE"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when issuer is currently different' {
                    $response['Enabled'] = $true
                    $response['Issuer'] = "https://dev-258251.oktapreview.com"
                    $response['ClientID'] = "752nx5basdskrsbqansE"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when the clientid is currently different' {
                    $response['Enabled'] = $true
                    $response['Issuer'] = "https://dev-258250.oktapreview.com"
                    $response['ClientID'] = "73sfca4fvbsfnw42huDs"
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
                                       -Enabled $true `
                                       -Issuer "https://dev-258250.oktapreview.com" `
                                       -ClientID "752nx5basdskrsbqansE"
                    Assert-MockCalled Invoke-OctopusServerCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'configure --console --instance SuperOctopus --oktaIsEnabled true --oktaIssuer https://dev-258250.oktapreview.com --oktaClientId 752nx5basdskrsbqansE'}
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
