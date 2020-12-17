return @{
  Ensure = "Present";
  State = "Started";
  DownloadUrl = "https://octopus.com/downloads/latest/WindowsX64/OctopusServer";
  HomeDirectory = "C:\Octopus";
  TaskLogsDirectory = "C:\Octopus\TaskLogs"
  LogTaskMetrics = $false;
  LogRequestMetrics = $false;
  ListenPort = 10935;
  WebListenPrefix = "http://localhost:82";
  ForceSSL = $false
  SqlDbConnectionString = "Server=(local);Database=Octopus;Trusted_Connection=True;";
  OctopusBuiltInWorkerCredential = [PSCredential]::Empty;
  OctopusMasterKey = [PSCredential]::Empty;
 }
