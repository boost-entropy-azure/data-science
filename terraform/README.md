# Data Science Core Infrastructure Deploy

This repo can be used to deploy a data science infrastructure in Azure using Terragrunt, Terraform, and Ansible.

Currently, this Terraform configuration deploys the following resources to Azure

- A Resource Group
- A Virtual Network
- A Subnet
- A Network Security Group
- A storage account for boot diagnostics
- An IoT Hub
- An Event Hubs Namespace, and an Event Hub instance per specified MQTT topic
- An Azure data lake storage container
- An Azure File Share to store files for the docker containers
- A Mosquitto MQTT Broker in a Docker Container
- A MQTT to Event Hubs Connector in a Docker Container
- A VM with Apache Spark, and Jupyter Notebook

> More to follow.

## Dependencies

- HashiCorp [Terraform](https://www.terraform.io/downloads.html)
  - Version >= v0.13.4
- Gruntworks [Terragrunt](https://github.com/gruntwork-io/terragrunt/releases)
  - Version >= v0.25.3
- Ansible
  - Version >= v2.8
- Azure CLI

This should be executed from a Docker container, Linux/WSL or MacOS system. Container is the recommended approach.

### Terraform Module Dependencies

Order of dependencies:

- Infrastructure:

  1. Resource Group
  2. Network
  3. Security_Groups
  4. Storage
  5. Identities

- Application Stack:
  1. Eventhubs - Alert
  2. Eventhubs - MQTT
  3. DataSci - Nodes
  4. DataSci - Containers
  5. Fact Table
  6. Grafana
  7. Status Monitor
  8. Reverse Proxy

## Directory Structure

```bash
├── CHANGELOG.md
├── LICENSE.md
├── README.md
├── dev
│   ├── application_stack
│   ├── infrastructure
│   ├── terragrunt.hcl
│   ├── tg_environment_inputs.yml
│   └── tg_environment_variables.hcl [deprecated]
└── prod
    └── terragrunt.hcl
```

## Terragrunt HCL

Each environment contains a `terragrunt.hcl` at the top level (as well as child levels), this ensures that all the dependent Terraform states are mapped correctly, as well as pushes variables/artifacts down throughout all the child provisioners/modules. Terragrunt uses the "Don't Repeat Yourself (DRY)" philosophy, and we're trying to replicate that here.

For any variables, such as environment, user, etc., define those at the top level `<environment>/terragrunt.hcl`. This generates the below files on every child Terraform folder at runtime:

- \_\_backend.tf
- \_\_provider.tf
- \_\_variables.tf

These files are added under `.gitignore`, so they won't be committed to the repository, as Terragrunt regenerates at runtime. This keeps the overall Data Science repository clean, while allowing for easy environment navigation and precise state data adjustments.

## Environment Terraform Variables

- Defined globally under `tg_environment_variables.hcl`
  - Avoids the need to define a `variables.tf` file for every module, instead Terragrunt creates this file.
  - Simply add them to the `hcl` file node and Terragrunt will automate generation of the `variables.tf` per state.

## Environment Inputs

- Defined under `tg_environment_inputs.yml` or per-module at `inputs.yml`. Per-module inputs override Global, although this should be used sparing to avoid complicated dependency debugging.

## Execution

- To deploy an entire environment, execute this command: `terragrunt apply-all --terragrunt-working-dir dev/`
  - With `dev/'` aligning to the proper folder path in the above tree.
- To develop and test individual components, drill into the desired component directory and execute: `terragrunt apply`
  - Can also deploy at the top level, specifying the working directory: `terragrunt apply --terragrunt-working-dir dev/infrastructure/resource_groups/`

### Terragrunt Gotchas

The variables are passed via parent imports from Terragrunt's HCL files, so raw `terraform <action>` commands will result in undefined variables or missing inputs. Running `terragrunt <action>` avoids these issues, as Terragrunt will enumerate through parent directories to determine these values.

For example, these will provide the same result:

```bash
> pwd
pvr-azure-datasci-core
> terragrunt apply --terragrunt-working-dir dev/infrastructure/resource_groups/
## OR ##
> pwd
pvr-azure-datasci-core/dev/infrastructure/resource_groups
> terragrunt apply
```

## Destruction

Destruction of assets will not be an automated process. Tread with caution, as this is permanent and **WILL** result in data loss.

To remove an environment in it's entirety: `terragrunt destroy --terragrunt-working-dir dev/infrastructure/resource_groups/`

> Azure removes all dependent objects within the defined Resource Group

NOTE: Based on the Terraform bootstrap process, running this destroy **WILL NOT** remove the Terraform state data or storage container, as that is (and should be) provisioned outside of the main infrastructure states to ensure environment safety.

To remove a specific component, operates the same as the above `apply` examples:

```bash
> pwd
pvr-azure-datasci-core
> terragrunt destroy --terragrunt-working-dir /dev/application_stack/datasci_nodes
## OR ##
> pwd
pvr-azure-datasci-core/dev/application_stack/datasci_nodes
> terragrunt destroy
```

NOTE: Due to interlocking dependencies that can get quite complicated throughout the full stack, ensure all dependent modules are updated after a destroy/re-create. (i.e, IP addresses change)

Highly simplified example of that particular workflow:

```bash
> pwd
pvr-azure-datasci-core
> terragrunt destroy --terragrunt-working-dir /dev/application_stack/datasci_nodes
> terragrunt apply --terragrunt-working-dir /dev/application_stack/datasci_nodes
> terragrunt apply-all --terragrunt-working-dir /dev/application_stack/
# This would only update/redeploy assets effected by changes in the datasci_nodes module
```

## Feature Requests/Action Items

TODO: Need to discuss environment provisioning; the Vagrant dependencies are removed (and moved to another repository for "dev machine")
TODO: Better handle VM creation between duplicating modules (use tagging->mapped to Ansible roles??)
TODO: Clean up variable declarations between Terragrunt and upstream modules
TODO: Test SSH access using dynamic key
