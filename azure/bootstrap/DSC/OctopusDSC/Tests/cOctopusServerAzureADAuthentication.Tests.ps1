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

        Describe 'cOctopusServerAzureADAuthentication' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     InstanceName            = 'OctopusServer'
                     Enabled                 = $true
                     Issuer                  = "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
                     ClientID                = "0272262a-b31d-4acf-8891-56e96d302018"
                }
            }

            Context 'Get-TargetResource' {
                It 'Returns the proper data' {
                    Mock Test-Path { return $true } -ParameterFilter { $LiteralPath -eq "$($env:ProgramFiles)\Octopus Deploy\Octopus\Octopus.Server.exe" }
                    Mock Test-OctopusVersionSupportsAuthenticationProvider { return $true }
                    Mock Get-ServerConfiguration {
                        return  @{
                            Octopus = @{
                                AzureAD = @{
                                    IsEnabled = $true;
                                    Issuer = "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
                                    ClientID = "0272262a-b31d-4acf-8891-56e96d302018"
                                }
                            }
                        }
                    }

                    $config = Get-TargetResource @desiredConfiguration
                    $config.InstanceName    | Should -Be 'OctopusServer'
                    $config.Enabled         | Should -Be $true
                    $config.Issuer          | Should -Be "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
                    $config.ClientID        | Should -Be "0272262a-b31d-4acf-8891-56e96d302018"
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
                    $response['Issuer'] = "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
                    $response['ClientID'] = "0272262a-b31d-4acf-8891-56e96d302018"

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Returns false when its currently disabled' {
                    $response['Enabled'] = $false
                    $response['Issuer'] = "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
                    $response['ClientID'] = "0272262a-b31d-4acf-8891-56e96d302018"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when issuer is currently different' {
                    $response['Enabled'] = $true
                    $response['Issuer'] = "https://login.microsoftonline.com/32a1d0a11c8a-b91ebf6a-84be-4c6f-97f3"
                    $response['ClientID'] = "0272262a-b31d-4acf-8891-56e96d302018"

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false when the clientid is currently different' {
                    $response['Enabled'] = $true
                    $response['Issuer'] = "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a"
                    $response['ClientID'] = "56e96d302018-0272262a-b31d-4acf-8891"
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
                                       -Issuer "https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a" `
                                       -ClientID "0272262a-b31d-4acf-8891-56e96d302018"
                    Assert-MockCalled Invoke-OctopusServerCommand -ParameterFilter { ($cmdArgs -join ' ') -eq 'configure --console --instance SuperOctopus --azureADIsEnabled true --azureADIssuer https://login.microsoftonline.com/b91ebf6a-84be-4c6f-97f3-32a1d0a11c8a --azureADClientId 0272262a-b31d-4acf-8891-56e96d302018'}
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
