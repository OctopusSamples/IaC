@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '4.0.934'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'cebaa69e-f83e-441b-a818-70c0e5c6cf46'

# Author of this module
Author = 'Paul Stovell'

# Company or vendor of this module
CompanyName = 'Octopus Deploy Pty. Ltd.'

# Copyright statement for this module
Copyright = '(c) 2016 Octopus Deploy Pty. Ltd. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Module with DSC resource to install and configure an Octopus Deploy Server and Tentacle agent.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
CLRVersion = '4.0'

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Get-TargetResource', 'Set-TargetResource', 'Test-TargetResource'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
DscResourcesToExport = @('cOctopusEnvironment', 'cOctopusSeqLogger', 'cOctopusServer', 'cOctopusServerActiveDirectoryAuthentication', 'cOctopusServerAzureADAuthentication', 'cOctopusServerGoogleAppsAuthentication', 'cOctopusServerGuestAuthentication', 'cOctopusServerOktaAuthentication', 'cOctopusServerSpace', 'cOctopusServerUsernamePasswordAuthentication', 'cOctopusServerWatchdog', 'cOctopusWorkerPool', 'cTentacleAgent', 'cTentacleWatchdog')

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'dsc-resources','dsc','OctopusDeploy'

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/OctopusDeploy/OctopusDSC'

        # A URL to an icon representing this module.
        IconUri = 'https://github.com/OctopusDeploy/OctopusDSC/blob/master/OctopusDSC/Octopus_blue_64px.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # External dependent modules of this module
        # ExternalModuleDependencies = ''

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

