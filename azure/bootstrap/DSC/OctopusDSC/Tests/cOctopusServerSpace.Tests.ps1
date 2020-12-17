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

        Describe 'cOctopusServerSpace' {
            BeforeEach {
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
                $desiredConfiguration = @{
                     Url                = 'https://octopus.example.com'
                     Ensure             = 'Present'
                     Name               = 'Integration Team'
                     Description        = 'The integration team space'
                     SpaceManagersTeamMembers = @("admin")
                     SpaceManagersTeams = @("Everyone")
                     OctopusCredentials = $creds
                }
            }

            Context 'Get-TargetResource - error scenarios' {
                It 'Throws when both OctopusCredentials and OctopusApiKey are provided' {
                    {Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -Name 'Integration Team' `
                                                 -Description 'Integration team space' `
                                                 -SpaceManagersTeamMembers @('admin') `
                                                 -SpaceManagersTeams @('Everyone') `
                                                 -OctopusCredentials $creds `
                                                 -OctopusApiKey $creds } | Should -throw "Please provide either 'OctopusCredentials' or 'OctopusApiKey', not both."
                }

                It 'Throws when neither OctopusCredentials and OctopusApiKey are provided' {
                    {Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -Name 'Integration Team' `
                                                 -Description 'Integration team space' `
                                                 -SpaceManagersTeamMembers @('admin') `
                                                 -SpaceManagersTeams @('Everyone') } | Should -throw "Please provide either 'OctopusCredentials' or 'OctopusApiKey'."
                }

                #todo: throw if neither SpaceManagersTeams or SpaceManagersTeamMembers not provided
                It 'Throws when neither SpaceManagersTeams or SpaceManagersTeamMembers are provided' {
                    {Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -Name 'Integration Team' `
                                                 -Description 'Integration team space' `
                                                 -OctopusApiKey $creds } | Should -throw "Please provide at least one of 'SpaceManagersTeamMembers' or 'SpaceManagersTeams'."
                }
            }

            Context 'Get-TargetResource - when present' {
                It 'Returns present when space exists' {
                    Mock Get-Space { return [PSCustomObject]@{ Name = 'Integration Team'; Description = 'The integration team space' } }
                    Mock Update-Space
                    $result = Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -Name 'Integration Team' `
                                                 -Description 'The integration team space' `
                                                 -SpaceManagersTeamMembers @('admin') `
                                                 -SpaceManagersTeams @('Everyone') `
                                                 -OctopusCredentials $creds
                    $result.Ensure | Should -Be 'Present'
                }
            }

            Context 'Get-TargetResource - when absent' {
                It 'Returns absent when space does not exist' {
                    Mock Get-Space { return $null }
                    $result = Get-TargetResource -Url 'https://octopus.example.com' `
                                                 -Ensure 'Present' `
                                                 -Name 'Integration Team' `
                                                 -Description 'The integration team space'  `
                                                 -SpaceManagersTeamMembers @('admin') `
                                                 -SpaceManagersTeams @('Everyone') `
                                                 -OctopusCredentials $creds
                    $result.Ensure | Should -Be 'Absent'
                }
            }

            Context 'Test-TargetResource' {
                BeforeAll {
                    $response = @{  }
                    Mock Get-TargetResource { return $response }
                }

                It 'Returns false if space does not exist' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['Name'] = 'Integration Team'
                    $desiredConfiguration['Description'] = 'The integration team space'
                    $desiredConfiguration['SpaceManagersTeamMembers'] = @('admin')
                    $desiredConfiguration['SpaceManagersTeams'] = @('Everyone')

                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['Name'] = $null
                    $response['Description'] = $null
                    $response['SpaceManagersTeamMembers'] = $null
                    $response['SpaceManagersTeams'] = $null
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns true if space does exist and all properties match' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['Name'] = 'Integration Team'
                    $desiredConfiguration['Description'] = 'The integration team space'
                    $desiredConfiguration['SpaceManagersTeamMembers'] = @('admin')
                    $desiredConfiguration['SpaceManagersTeams'] = @('Everyone')
                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['Name'] = 'Integration Team'
                    $response['Description'] = 'The integration team space'
                    $response['SpaceManagersTeamMembers'] = @('admin')
                    $response['SpaceManagersTeams'] = @('Everyone')
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $true
                }

                It 'Returns false if description is different' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['Name'] = 'Integration Team'
                    $desiredConfiguration['Description'] = 'The integration team space'
                    $desiredConfiguration['SpaceManagersTeamMembers'] = @('admin')
                    $desiredConfiguration['SpaceManagersTeams'] = @('Everyone')
                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['Name'] = 'Integration Team'
                    $response['Description'] = 'wrong description'
                    $response['SpaceManagersTeamMembers'] = @('admin')
                    $response['SpaceManagersTeams'] = @('Everyone')
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false if SpaceManagersTeamMembers is different' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['Name'] = 'Integration Team'
                    $desiredConfiguration['Description'] = 'The integration team space'
                    $desiredConfiguration['SpaceManagersTeamMembers'] = @('admin')
                    $desiredConfiguration['SpaceManagersTeams'] = @('Everyone')
                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['Name'] = 'Integration Team'
                    $response['Description'] = 'The integration team space'
                    $response['SpaceManagersTeamMembers'] = @('bob')
                    $response['SpaceManagersTeams'] = @('Everyone')
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Returns false if SpaceManagersTeams is different' {
                    $password = ConvertTo-SecureString "1a2b3c4d5e6f" -AsPlainText -Force
                    $creds = New-Object System.Management.Automation.PSCredential ("username", $password)

                    $desiredConfiguration['Url'] = 'https://octopus.example.com'
                    $desiredConfiguration['Ensure'] = 'Present'
                    $desiredConfiguration['Name'] = 'Integration Team'
                    $desiredConfiguration['Description'] = 'The integration team space'
                    $desiredConfiguration['SpaceManagersTeamMembers'] = @('admin')
                    $desiredConfiguration['SpaceManagersTeams'] = @('Everyone')
                    $desiredConfiguration['OctopusCredentials'] = $creds

                    $response['Url'] = 'https://octopus.example.com'
                    $response['Ensure'] = 'Present'
                    $response['Name'] = 'Integration Team'
                    $response['Description'] = 'The integration team space'
                    $response['SpaceManagersTeamMembers'] = @('admin')
                    $response['SpaceManagersTeams'] = @('TeamX')
                    $response['OctopusCredentials'] = $creds

                    Test-TargetResource @desiredConfiguration | Should -Be $false
                }

                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    Test-TargetResource @desiredConfiguration
                    Assert-MockCalled Get-TargetResource
                }
            }

            Context 'Set-TargetResource - when present' {
                It 'Calls Remove-Space if present and ensure set to absent' {
                    Mock Get-Space { return [PSCustomObject]@{ Name = 'Integration Team' } }
                    Mock New-Space
                    Mock Remove-Space
                    $desiredConfiguration['Ensure'] = 'Absent'
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Remove-Space -Exactly 1
                }
            }

            Context 'Set-TargetResource - when absent' {
                It 'Calls New-Space if not present and ensure set to present' {
                    Mock Get-Space { return $null }
                    Mock New-Space
                    Mock Remove-Space
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled New-Space -Exactly 1
                }
            }

            Context 'Set-TargetResource - when description are different' {
                It 'Calls Update-Space when description is different' {
                    $response = @{
                        Url = 'https://octopus.example.com';
                        Ensure='Present';
                        Name = 'Integration Team';
                        Description = 'a different description';
                        SpaceManagersTeamMembers = @('admin');
                        SpaceManagersTeams = @('Everyone');
                        OctopusCredentials = $creds }
                    Mock Get-TargetResource { return $response }
                    Mock Update-Space { return $null }
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Update-Space -Exactly 1
                }
            }

            Context 'Set-TargetResource - when SpaceManagersTeamMembers are different' {
                It 'Calls Update-Space when SpaceManagersTeamMembers is different' {
                    $response = @{
                        Url = 'https://octopus.example.com';
                        Ensure='Present';
                        Name = 'Integration Team';
                        Description = 'a different description';
                        SpaceManagersTeamMembers = @('admin');
                        SpaceManagersTeams = @('Everyone');
                        OctopusCredentials = $creds }
                    Mock Get-TargetResource { return $response }
                    Mock Update-Space { return $null }
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Update-Space -Exactly 1
                }
            }

            Context 'Set-TargetResource - when SpaceManagersTeams are different' {
                It 'Calls Update-Space when SpaceManagersTeams is different' {
                    $response = @{
                        Url = 'https://octopus.example.com';
                        Ensure='Present';
                        Name = 'Integration Team';
                        Description = 'The integration team space';
                        SpaceManagersTeamMembers = @('admin');
                        SpaceManagersTeams = @('Team X');
                        OctopusCredentials = $creds }
                    Mock Get-TargetResource { return $response }
                    Mock Update-Space { return $null }
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Update-Space -Exactly 1
                }
            }

            Context 'Set-TargetResource - no changes' {
                It 'Calls Get-TargetResource (and therefore inherits its checks)' {
                    $response = @{
                        Url = 'https://octopus.example.com';
                        Ensure='Present';
                        Name = 'Integration Team';
                        Description = 'The integration team space';
                        SpaceManagersTeamMembers = @('admin');
                        SpaceManagersTeams = @('Everyone');
                        OctopusCredentials = $creds }
                    Mock Get-TargetResource { return $response }
                    Mock Update-Space { return $null }
                    Set-TargetResource @desiredConfiguration
                    Assert-MockCalled Get-TargetResource -Exactly 1
                    # we would expect to check that Update-Space is not called
                    # but as Set-TargetResource is only called by DSC when there
                    # are changes, so Set-TargetResource can safely assume that
                    # changes are required
                }
            }

            Context 'Team and User mapping' {
                BeforeAll {
                    $spacesRepository = New-Object -TypeName PSObject
                    $getSpaceResponse = @{
                        Id = "Spaces-262";
                        Name = "Integration Space";
                        Description = "The old description";
                        IsDefault = $false;
                        TaskQueueStopped = $false;
                        SpaceManagersTeams = @("teams-spacemanagers-Spaces-262", "teams-everyone");
                        SpaceManagersTeamMembers = @("Users-582") }
                    $spacesRepository | Add-Member -MemberType ScriptMethod -Name "FindByName" -Force -Value { return $getSpaceResponse }
                    $script:valueReceivedByModifyFunction = $null
                    $spacesRepository | Add-Member -MemberType ScriptMethod -Name "Modify" -Force -Value { param($space) $script:valueReceivedByModifyFunction = $space }
                    $script:valueReceivedByCreateFunction = $null
                    $spacesRepository | Add-Member -MemberType ScriptMethod -Name "Create" -Force -Value { param($space) $script:valueReceivedByCreateFunction = $space }

                    $usersRepository = New-Object -TypeName PSObject
                    $findUsersResponse = @(@{ Id = "Users-1001"; Username = "bob@example.com"}, @{ Id = "Users-582"; Username = 'admin'} )
                    $usersRepository | Add-Member -MemberType ScriptMethod -Name "FindAll" -Force -Value { return $findUsersResponse }

                    $teamsRepository = New-Object -TypeName PSObject
                    $findTeamsResponse = @(
                        @{ Id = "teams-everyone"; Name = "Everyone"; SpaceId = $null },
                        @{ Id = "teams-spacemanagers-Spaces-271"; Name = 'Space Managers'; SpaceId = 'Spaces-271'},  # team in a diff space
                        @{ Id = "teams-spacemanagers-Spaces-262"; Name = 'Space Managers'; SpaceId = 'Spaces-262'} )
                    $teamsRepository | Add-Member -MemberType ScriptMethod -Name "FindAll" -Force -Value { return $findTeamsResponse }

                    $mockRepository = New-Object -TypeName PSObject -Property @{
                        Spaces = $spacesRepository
                        Teams = $teamsRepository
                        Users = $usersRepository
                    }
                    Mock Get-OctopusClientRepository { return $mockRepository }
                }

                Context 'Get-Space' {

                    It 'Maps user ids returned by api to names' {
                        $space = Get-Space `
                            -Url 'https://octopus.example.com' `
                            -Name 'Integration Team' `
                            -OctopusCredentials $null `
                            -OctopusApiKey $null
                        $space.SpaceManagersTeamMembers | Should -Be @('admin')
                    }
                    It 'Maps team ids returned by api to names' {
                        $space = Get-Space `
                            -Url 'https://octopus.example.com' `
                            -Name 'Integration Team' `
                            -OctopusCredentials $null `
                            -OctopusApiKey $null
                        $space.SpaceManagersTeams | Should -Be @('Space Managers', 'Everyone')
                    }
                }

                Context 'Update-Space' {
                    BeforeAll {
                        Update-Space `
                            -Url 'https://octopus.example.com' `
                            -Name 'Integration Team' `
                            -Description 'The new description' `
                            -SpaceManagersTeamMembers @('admin') `
                            -SpaceManagersTeams @('Everyone') `
                            -OctopusCredentials $null `
                            -OctopusApiKey $null
                    }
                    It 'Maps user names supplied by user to ids' {
                        $script:valueReceivedByModifyFunction.SpaceManagersTeamMembers | Should -Be @("Users-582")
                    }
                    It 'Maps team names supplied by user to ids and adds space managers' {
                        $script:valueReceivedByModifyFunction.SpaceManagersTeams | Should -Be @("teams-everyone", "teams-spacemanagers-Spaces-262")
                    }
                }

                Context 'New-Space' {
                    BeforeAll {
                        Mock New-SpaceResource { return @{} }
                        Mock ConvertTo-ReferenceCollection { param($list) return $list }
                        New-Space `
                            -Url 'https://octopus.example.com' `
                            -Name 'Integration Team' `
                            -Description 'The new description' `
                            -SpaceManagersTeamMembers @('admin') `
                            -SpaceManagersTeams @('Everyone') `
                            -OctopusCredentials $null `
                            -OctopusApiKey $null
                    }
                    It 'Maps user names supplied by user to ids' {
                        $script:valueReceivedByCreateFunction.SpaceManagersTeamMembers | Should -Be @("Users-582")
                    }
                    It 'Maps team names supplied by user to ids and adds space managers' {
                        $script:valueReceivedByCreateFunction.SpaceManagersTeams | Should -Be @("teams-everyone")
                    }
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
