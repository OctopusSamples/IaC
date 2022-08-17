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

The goal of the terrform file is to ensure all spaces on the samples instance get the same base set of resources.  These include (but not limited to):

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

### Terraform File Structure

Having one massive `main.tf` is not sustainable.  Besides, Terraform has no concept of a "single controlling file" rather it looks at a directory and combines every one of the .tf files it can find.  To that end, this is the structure.

- `main.tf` -> stores the providers and backend information
- `variables.tf` -> stores all the variables used across all the files to make it easy to match up when sending variables from Octopus
- [resource-type].tf -> a file storing all the similar resources, for example a file for worker pools, another for external feeds, etc.
    - When resources are isolated (accounts, worker pools, infrastructure accounts), put them all in a single file
    - Each library variable set will get its own file as a library variable set can have 1 to N variables.  Having one file for all variable sets would be very hard to maintain.
    - If you need to share values, for example a worker pool library variable set includes all the worker pool names created by the TF provider, then use variables with a default value.
    - Descriptive file names are preferred

### Making Changes
It can be hard to test changes to these files.  To help with that, the runbook [Terraform Research](https://samples-admin.octopus.app/app#/Spaces-1/projects/standards/operations/runbooks/Runbooks-48/overview) has been created.  

- Unlike the main space standards runbook, this runbook uses inline code.
- It will create the resource, allow you to review via a manual intervention, then it will destroy the resource.
- Everything created by this runbook has a separate state file from the space standards state file.
- When making changes, be sure to update both the apply and destroy steps.
- You can only run this runbook on the default spaces in the samples-sandbox instance.  You don't have to worry about messing up anyone.

Terraform is a powerful tool.  When making changes to these files ask yourself "will I be able to understand this in six months?" and "would a new person understand this?"  If the answer is no, then re-think the approach.  

To make changes to the TF files in this repo:

1. If you are unsure of an approach or something isn't working, use the [Terraform Research](https://samples-admin.octopus.app/app#/Spaces-1/projects/standards/operations/runbooks/Runbooks-48/overview) runbook.  You can skip this step if you are reasonably sure your changes will work.
2. Modify and/or create the appropriate TF file.
3. Submit a PR
4. Once the PR is approved create a release.
5. Publish a snapshot of [the space standard runbook](https://samples-admin.octopus.app/app#/Spaces-1/projects/standards/operations/runbooks/Runbooks-21/overview).
