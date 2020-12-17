# Configures a polling tentacle and automatically registers it with the specified server
# please see https://github.com/OctopusDeploy/OctopusDSC/blob/master/README-cTentacleAgent.md for all available options

Configuration SampleConfig
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification="ReviewUnusedParameter does not capture parameter usage within a scriptblock.  See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472")]
    param ([string]$ApiKey, [string]$OctopusServerUrl, [string[]]$Environments, [string[]]$Roles, [int]$ServerPort, [string]$Space)

    Import-DscResource -Module OctopusDSC

    Node "localhost"
    {
        cTentacleAgent OctopusTentacle
        {
            Ensure = "Present"
            State = "Started"

            # Tentacle instance name. Leave it as 'Tentacle' unless you have more
            # than one instance
            Name = "Tentacle"

            # Registration
            ApiKey = $ApiKey
            OctopusServerUrl = $OctopusServerUrl
            Environments = $Environments
            Roles = $Roles
            # Spaces are supported for Octopus Server 2019.1 and above. If null or not specified, it uses the default space
            Space = $Space

            # How Tentacle will communicate with the server
            CommunicationMode = "Poll"
            ServerPort = $ServerPort

            # Where deployed applications will be installed by Octopus
            DefaultApplicationDirectory = "C:\Applications"

            # Where Octopus should store its working files, logs, packages etc
            TentacleHomeDirectory = "C:\Octopus"
        }
    }
}
