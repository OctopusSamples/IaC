[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

return @{
    Ensure = "Present";
    State = "Stopped";
    Name = "Tentacle";
    RegisterWithServer = $false;
    TentacleHomeDirectory = "C:\Octopus"
    DefaultApplicationDirectory = "C:\Applications"
}
