# Data Science Core Infrastructure Deploy

This repo can be used to deploy a data science infrastructure in Azure using Terraform, Cloud-Init, and Ansible.

Currently, this Terraform configuration deploys the following resources to Azure:

- A Resource Group
- A Virtual Network
- A Subnet
- A Network Security Group
- A storage account for boot diagnostics
- An Event Hubs Namespace for Raw traffic, and an Event Hub instance per specified MQTT topic
- An Event Hubs Namespace for automated alerts, with one alert Event Hub instance
- An Azure data lake storage container
- VMs with Apache Spark, and Jupyter Notebook

## Dependencies

- HashiCorp [Terraform](https://www.terraform.io/downloads.html)
    - Version >= v0.13.4
- Ansible
    - Version >= v2.8
- Azure CLI

This should be executed from a Docker container, Linux/WSL or MacOS system. A container is the recommended approach.

### Terraform Module Dependencies

Order of dependencies:

- Infrastructure:

    1. Resource Group
    1. Network
    1. Security_Groups
    1. Storage
    1. Identities

- Application Stack:

    1. Event Hub Namespace - Alert
    1. Event Hub Namespace - MQTT
    1. DataSci - Nodes
    1. Fact Table
    1. Status Monitor
    1. Reverse Proxy

## Directory Structure

```bash
├── modules
│   ├── README.md
│   ├── mod-azure-datasci-eventhubs
│   ├── mod-azure-datasci-fact-table
│   ├── mod-azure-datasci-grafana
│   └── mod-azure-datasci-nodes
├── providers
│   ├── application_stack
│   │   ├── backend.tf
│   │   ├── data.tf
│   │   ├── datasci_nodes.tf
│   │   ├── eventhubs.tf
│   │   ├── fact_table.tf
│   │   ├── grafana.tf
│   │   ├── required_provider.tf
│   │   └── variables.tf
│   └── infrastructure
│       ├── backend.tf
│       ├── data.tf
│       ├── datasci-container.json
│       ├── identities.tf
│       ├── locals.tf
│       ├── network.tf
│       ├── providers.tf
│       ├── resource_group.tf
│       ├── security_groups.tf
│       ├── storage.tf
│       └── variables.tf
└── remote-state-bootstrap
    ├── README.md
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

## Overview

The Data Science deployment is broken into 2 parts, the infrastructure and application stack. Each part maintains its
own Terraform remote state in order to minimize the blast radius of destructive changes.

Ideally, these states will reside outside the Azure Resource Groups Terraform is managing. To assist with this, another
Terraform module is provided under `./terraform/remote-state-boostrap` to create those necessary dependencies.

The high level workflow of deploying the pipeline is a follows:

1. Create Azure storage for remote state
2. Deploy Infrastructure (`./terraform/providers/infrastructure`)
3. Deploy Application Stack (`./terraform/providers/application_stack`)

The `infrastructure` components are broken into resource-defined Terraform files and the `application stack` components
are deployed via modules, located in this same repository under `./terraform/modules`. This increases the ability to
push changes and modifications without multiple Git repositories and versioning. Note, as the development team or
project grows, this methodology is subject to change to enhance protection of the data and integrity of the deployments.

### Ansible/Cloud-Init

To avoid prolonged execution times and minimize `null_resource` call outs as recommended by HashiCorp, all the
Ansible-based provisioning and configuration management is initiated via Cloud-Init. This allows for Ansible changes to
be managed and updated outside the Terraform state.

Cloud-Init and Ansible execution can be reviewed from within the Azure Portal for each Virtual Machine here:
`Boot diagnostics` -> `Serial Log`

The [Ansible Datasci Roles repo](https://github.com/chesapeaketechnology/ansible-datasci-roles) is responsible for
provisioning the VMs that run Spark and Jupyter Notebook.

### Azure Key Vault

In order to enhance the security of the pipeline, by default Terraform will determine the local workstation IP and pass
that as the only "source address" that can reach the Data Science environment.

To complement this feature within a shared state and automation, Azure Key Vault lookups were added. The default
behavior is to simply `curl https://ipecho.net/plain` and add that IP as the source.

However, set this variable `source_from_vault=true`, and Terraform will perform lookups to an Azure Key Vault.

With the lookup enabled, Terraform expects a few additional variables:

```bash
source_from_vault -> Boolean to true
azure_keyvault_resource_group_name -> Resource Group of Key Vault
azure_keyvault_name -> Azure Key Vault Name
azure_keyvault_secret1 -> CSV Secret to Lookup
```

Sample environment deploy:

```bash
export TF_VAR_source_from_vault=true
export TF_VAR_azure_keyvault_resource_group_name=""
export TF_VAR_azure_keyvault_name=""
export TF_VAR_azure_keyvault_secret1=""
```

On the Azure Key Vault side, the `azure_keyvault_secret1` secret is expected to be in a comma separated value
format: `1.1.1.1,2.2.2.2,3.3.3.3`. If it is not, Terraform will have parsing errors.

## Deployment Steps

To deploy the resources defined in the Terraform code from this repo, use the steps
provided [here in the Step-by-step Guide](https://chesapeaketechnology.github.io/data-science/#_step_by_step_guide)

## Destruction

To delete the resources defined in the Terraform code from this repo, use the steps
provided [here in the Destruction Guide](https://chesapeaketechnology.github.io/data-science/#_destruction)
