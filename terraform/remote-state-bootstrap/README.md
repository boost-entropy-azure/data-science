# remote-state-terraform-bootstrap

This folder contains a manual bootstrap configuration for Terraform infrastructure as code. At present it contains the Terraform code needed to create a shared state backend. For this current deployment, we are leveraging the Azure backend, so the AWS related information is not applicable. Future enhancement will likely be a boolean option.

Only execute and save this data **ONCE**. This does not have a remote state itself and the state data will not be saved within Git after execution. Use the `outputs` from the deployment to gather the required information, then archive this project.

## Overview

- [Description](##Description)
- [Prerequisites](##Prerequisites)
- [AWS Deployment](<##AWS\ Deployment>)
  - [AWS Backends](<###AWS\ Backends>)
- [Azure Deployment](<##Azure\ Deployment>)
  - [Azure Backends](<###Azure\ Backends>)
- [License](##License)

## Description

Along with preventing sensitive state data from residing within Git, remote backends allows for multiple administrators to manage Terraform's environments with limited risk of locking or untracked delta changes.

For this deployment, and as a best practice, this Terraform state should remain disconnected from the overall infrastructure state, so this module should be executed once per account and not imported into the primary infrastructure states. This simply adds another level of protection within Terraform's states.

## Prerequisites

This code assumes the following:

- Proper destination cloud account is already configured
- Appropriate access is given to create configuration contained within
- Basic familiarity with Terraform
- Terraform version >= v0.13

## AWS Deployment

```bash
## You must specify the following environment variables
export AWS_ACCESS_KEY_ID="youraccesskey"
export AWS_SECRET_ACCESS_KEY="yoursecretkey"
export AWS_DEFAULT_REGION="us-awesome-1"

terraform init
terraform plan #validate changes
terraform apply

# confirm and watch it go crazy
```

### AWS Backends

This Terraform configuration creates the following objects:

- S3 bucket for centralized state
  - This bucket cannot be deleted without policy modification
- DynamoDB for session locking
- S3 Generalized Hardening
- IAM policy to control the S3 bucket access

Upon execution of this code, you should add the following code block into any infrastructure Terraform modules:

```hcl
terraform {
  backend "s3" {
    bucket         = "<s3_bucket_name>"
    key            = "<env>/terraform.tfstate"
    region         = "<aws_region>"
    dynamodb_table = "tfstate-locks"
    encrypt        = true
  }
. . .
```

## Azure Deployment

```bash
## You must specify the following environment variables
export ARM_CLIENT_ID="client_id_here"
export ARM_CLIENT_SECRET="client_secret"
export ARM_SUBSCRIPTION_ID="subscription_id"
export ARM_TENANT_ID="tenant_id"


terraform init
terraform plan #validate changes
terraform apply

# confirm and watch it go crazy
```

### Azure Backends

This Terraform configuration creates the following objects:

- Blob container for centralized state
  - This bucket cannot be deleted without policy modification
- Policy to control container access

Upon execution of this code, you should add the following code block into any infrastructure Terraform modules to initiate the backend. These values are presented with the output of the module.

```hcl
terraform {
  backend "azurerm" {
    container_name       = "<storage_container_name>"
    key                  = "<env>/<role>/terraform.tfstate"
    resource_group_name  = "<resource_group_name>"
    storage_account_name = "<storage_account_id>"
  }
}
. . .
```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
