# Octopus Samples Instance IaC

This section contains scripts used to enforce standards on the samples instances used by Customer Solutions Team at Octopus Deploy.  It is made up of two sections, Terraform and API scripts.

## API Scripts

Ideally, the vast majority of our standards would be managed by the Octopus Terraform Provider or by Octopus Config as Code.  There were two roadblocks to that approach.

1) Octopus automatically creates a number of items.  For example, default lifecycle and system teams.
2) We want to be able to add items in our samples via the UI and still have them fall under our standards.

The API scripts will enforce standards for items outside of the control of the Octopus Terraform provider.  These include:

- Every space has the same set of base environments.
- Every space's lifecycles only keep releases for [x] number of days.
- Every space's runbooks only keep [x] number of runs per environment.
- Every space has the same set of base community step templates and those templates are kept up to date.
- The everyone team has read-only access to all spaces.
- Anyone in the Octopus Deploy employees team has release creator, deployment creator, and runbook consumer on all spaces.
- Anyone in the Octopus Managers team has space manager access on all spaces.

## Terraform

These files use the [Octopus Terraform Provider](https://registry.terraform.io/providers/OctopusDeployLabs/octopusdeploy/latest).  

The goal of the terrform file is to ensure all spaces on the samples instance get the same base set of resources.  These include (but not limitedt to):

- Accounts
    - AWS Account to AWS Solutions Sandbox
    - Azure Account to Azure Solutions Sandbox
    - GCP Account to GCP Solutions Sandbox
- Worker Pools
    - AWS Worker Pool to access AWS resources
    - Azure Worker Pool to access Azure resources
    - GCP Worker Pool to access GCP resources
- External Feeds
    - Feedz.io for NuGet Packages
    - GitHub for external scripts
    - DockerHub for execution containers and other docker images

The state for each space is maintained in a secured S3 bucket.  

Due to the sensitive nature of a lot of the variables, we do not have a .tfvars file.  Instead, all variables are injected during the apply step running on Octopus Deploy.