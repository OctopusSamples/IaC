[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

return @{
  Ensure = "Present";
  State = "Installed";
  DownloadUrl = "https://octopus-testing.s3.amazonaws.com/server/Octopus.2018.2.7-x64.msi"
}
