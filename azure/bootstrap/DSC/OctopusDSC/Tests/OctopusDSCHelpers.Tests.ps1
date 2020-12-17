$moduleName = Split-Path ($PSCommandPath -replace '\.Tests\.ps1$', '') -Leaf
$modulePath = Split-Path $PSCommandPath -Parent
$script:modulePath = Resolve-Path "$PSCommandPath/../../$moduleName.ps1"

. $script:modulePath

$script:SamplePath = Split-Path $PSCommandPath -parent
$script:samplePath = Resolve-path "$script:SamplePath/SampleConfigs/"

Describe "Get-ODSCParameter" {
    BeforeAll {
        . $script:modulePath
    }

    It "should be able to return our known default values" {
        $desiredConfiguration = @{
            Name                   = 'Stub'
            Ensure                 = 'Present'
        }
        (Test-GetODSCParameter @desiredConfiguration).DefaultValue | Should -Be 'default'
    }
}

Describe "Request-File" {
    Context "It shouldn't download when hashes match" {
        BeforeAll {
            . $script:modulePath
            Mock Invoke-WebRequest {
                return [pscustomobject]@{
                    Headers = @{'x-amz-meta-sha256' = "abcdef1234567890"};
                }
            } -Verifiable
            Mock Invoke-WebClient -Verifiable

            Mock Get-FileHash { return [pscustomobject]@{Hash =  "abcdef1234567890"} }
            Mock Test-Path { return $true }
        }
        It "Should only request the file hash and not download the file" {
            Request-File 'https://octopus.com/downloads/latest/WindowsX64/OctopusServer' $env:tmp\OctopusServer.msi # -verbose
            Assert-MockCalled "Invoke-WebRequest" -ParameterFilter {$Method -eq "HEAD" } -Times 1
            Assert-MockCalled "Invoke-WebClient" -Times 0
        }
    }

    Context "It should download when hashes mismatch" {
        BeforeAll {
            . $script:modulePath
            Mock Invoke-WebRequest {
                return [pscustomobject]@{
                    Headers = @{'x-amz-meta-sha256' = "abcdef1234567891"};
                }
            } -Verifiable
            Mock Invoke-WebClient -Verifiable

            Mock Get-FileHash { return [pscustomobject]@{Hash =  "abcdef1234567890"} }
            Mock Test-Path { return $true }
        }
        It "Should request the file has and also download the file" {
            Request-File 'https://octopus.com/downloads/latest/WindowsX64/OctopusServer' $env:tmp\OctopusServer.msi # -verbose
            Assert-MockCalled "Invoke-WebRequest"  -Times 1
            Assert-MockCalled "Invoke-WebClient" -Times 1
        }
    }
}

Describe "Invoke-OctopusServerCommand" {
    Context "It should not leak passwords" {

        BeforeAll {
            . $script:modulePath
            $octopusServerExePath = "echo"
            Write-Output "Mocked OctopusServerExePath as $OctopusServerExePath"
            Mock Write-Verbose { } -verifiable
            Mock Write-CommandOutput {}
        }

        It "Doesn't try to mask output when no sensitive values exist " {
            $npkargs = @("database",
                "--instance", "OctopusServer",
                "--connectionstring", "Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200;")
            Invoke-OctopusServerCommand $npkargs
            Assert-MockCalled Write-Verbose -parameterfilter { $Message -like "*echo database --instance OctopusServer --connectionstring Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200;*" } -times 1
        }

        It "Tries to mask the master key" {
            $dbargs = @("database",
                "--connectionstring", "Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200",
                "--masterKey", "ABCD123456ASDBD",
                "--instance", "OctopusServer")
            Invoke-OctopusServerCommand $dbargs
            Assert-MockCalled Write-Verbose -parameterfilter { $message -like "*echo database --connectionstring Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200 --masterKey *************** --instance OctopusServer'*"} -times 1  # has at least four asterisks
        }

        It "Tries to mask the Connectionstring password" {
            $pwargs = @("database",
                "--instance", "OctopusServer",
                "--connectionstring", "Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200;username=sa;password=p@ssword1234!")
            Invoke-OctopusServerCommand $pwargs
            Assert-MockCalled Write-Verbose -parameterfilter { $Message -like "*echo database --instance OctopusServer --connectionstring Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200;username=sa;password=********'*"}  -times 1
        }

        It "Tries to mask the licencebase64" {
            $lcargs = @("license",
                "--console",
                "--instance", "OctopusServer",
                "--licenseBase64", "khsandvlinfaslkndsafdvlkjnvdsakljnvasdfkjnsdavkjnvfwq45o3ragoahwer4")
            Invoke-OctopusServerCommand $lcargs
            Assert-MockCalled Write-Verbose -parameterfilter { $Message -like "*echo license --console --instance OctopusServer --licenseBase64 *******************************************************************'*"}  -times 1
        }

        It "Should successfully mask the SQL password" {
            $pwargs = @("database",
                "--instance", "OctopusServer",
                "--connectionstring", "Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200;username=sa;password=p@ssword1234!")
            ((Get-MaskedOutput $pwargs) -match "p@ssword1234!").Count | Should -Be 0
        }

        It "Should successfully mask a short-arg SQL password" {
            $pwargs2 = @("database",
                "--connectionstring", "Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200;username=sa;pwd=p@ssword1234!",
                "--instance", "OctopusServer")
            ((Get-MaskedOutput $pwargs2) -match "p@ssword1234!").Count | Should -Be 0
        }

        It "Should successfully mask the licence key" {
            $lcargs = @("license",
                "--console",
                "--instance", "OctopusServer",
                "--licenseBase64", "khsandvlinfaslkndsafdvlkjnvdsakljnvasdfkjnsdavkjnvfwq45o3ragoahwer4")
            $licence = "khsandvlinfaslkndsafdvlkjnvdsakljnvasdfkjnsdavkjnvfwq45o3ragoahwer4"
            ((Get-MaskedOutput $lcargs) -match $licence).Count | Should -Be 0
            ((Get-MaskedOutput $lcargs) -match "\*\*\*\*").Count -gt 0 | Should -Be $true
        }

        It "Should successfully mask the master key" {
            $dbargs = @("database",
                "--connectionstring", "Data Source=mydbserver;Initial Catalog=Octopus;Integrated Security=SSPI;Max Pool Size=200",
                "--masterKey", "ABCD123456ASDBD",
                "--instance", "OctopusServer")
            ((Get-MaskedOutput $dbargs) -match "ABCD123456ASDBD").Count | Should -Be 0
            ((Get-MaskedOutput $dbargs) -match "\*\*\*\*").Count -gt 0 | Should -Be $true
        }
    }
}

Describe "Test-ValidJson" {
    BeforeAll {
        . $script:modulePath
    }

    It "Returns false for known bad json" {
        Test-ValidJson (Get-Content "$script:SamplePath\octopus.server.exe-output-when-json-has-exception-prepended.json" -raw) | Should -Be $false
    }

    It "returns true for known good json" {
        Test-ValidJson (Get-Content "$script:SamplePath\octopus.server.exe-output-clean.json" -raw) | Should -Be $true
    }
}

Describe "Get-CleanedJson" {
    BeforeAll {
        . $script:modulePath
    }

    It "Correctly cleans our expected exception-prepended output" {
        Mock Write-Warning {} # supress warning text
        $clean = Get-CleanedJson (Get-Content "$script:SamplePath\octopus.server.exe-output-when-json-has-exception-prepended.json" -raw)
        Test-ValidJson $clean | Should -Be $true
        $clean -eq (Get-Content "$script:SamplePath\octopus.server.exe-output-clean.json" -raw) | Should -Be $true
    }
}
