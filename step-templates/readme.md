# Step Template Usage

These step templates are design to make it easy to spin up new VMs for the samples instance.  They were made with the following assumptions:

1) The virtual networks up in Azure/AWS/GCP/Whatever already exist, the VM is simply attaching to an existing one.  This allows us to configure security on other shared resources such as databases.
2) The VM is being deployed to a newly created CloudFormation stack or Azure Resource Group.  
3) The Bootstrap script will create a listening tentacle but it will _*not*_ register the VM with Octopus Deploy.  This is intentional, as you might have to restart the VM after configuration.

The anticipated order of spinning up VMs are:

1) Run the step template to create the VM in the cloud provider
2) Get the IP address from the cloud provider based on the name of the VM
3) Use the step template wait for machine to hit the port 10933 on the new VM.  It will hit that IP address every few seconds.  This ensures the bootstrap script has finished running.
4) Restart the VM to handle any additional installs (you can tell the bootstrap script to install additional software which might require a restart)
5) Register the VM as a worker or a target using the library step templates.
