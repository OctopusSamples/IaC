# Installs an Octopus Server instance against a local database
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cOctopusServer.md for all available options

# deserialize a password from disk
$password = Get-Content .\ExamplePassword.txt | ConvertTo-SecureString
$AdminCred = New-Object PSCredential "Admin", $password

$password = Get-Content .\ExamplePassword.txt | ConvertTo-SecureString
$runOnServerCred = New-Object PSCredential "RunAsUserAccount", $password

Configuration SampleConfig
{
    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cOctopusServer OctopusServer
        {
            Ensure = "Present"
            State = "Started"

            # Server instance name. Leave it as 'OctopusServer' unless you have more
            # than one instance
            Name = "OctopusServer"

            # The url that Octopus will listen on
            WebListenPrefix = "http://localhost:81"

            SqlDbConnectionString = "Server=(local)\SQLEXPRESS;Database=Octopus;Trusted_Connection=True;"

            # The admin user to create
            OctopusAdminCredential = $AdminCred

            # optional parameters
            AllowUpgradeCheck = $true
            AllowCollectionOfUsageStatistics = $true
            ForceSSL = $false
            ListenPort = 10943
            DownloadUrl = "https://octopus.com/downloads/latest/WindowsX64/OctopusServer"

            # for pre 3.5, valid values are "UsernamePassword" or "Domain"
            # for 3.5 and above, only "Ignore" is valid (this is the default value)
            LegacyWebAuthenticationMode = "UsernamePassword"

            HomeDirectory = "C:\Octopus"
            TaskLogsDirectory = "E:\OctopusTaskLogs" # defaults to "$HomeDirectory\TaskLogs"
            PackagesDirectory = "E:\OctopusPackages" # defaults to "$HomeDirectory\Packages"
            ArtifactsDirectory = "E:\OctopusArtifacts" # defaults to "$HomeDirectory\Artifacts"

            LicenseKey = "Base64 encoded xml license key"
            SkipLicenseCheck = $false

            # the user account to use for run-on-server tasks (optional)
            OctopusBuiltInWorkerCredential = $runOnServerCred

            TaskCap = 10
        }
    }
}
