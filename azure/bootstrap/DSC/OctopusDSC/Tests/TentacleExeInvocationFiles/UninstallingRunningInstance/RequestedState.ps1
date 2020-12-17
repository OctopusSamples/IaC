[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')] # these are tests, not anything that needs to be secure
param()

return @{
  Ensure = "Absent";
  Name = "Tentacle";
  OctopusServerUrl = "http://localhost:81";
  ApiKey = "API-1234";
}
