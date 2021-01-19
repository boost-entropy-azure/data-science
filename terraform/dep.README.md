# Data Science Core Infrastructure Deploy

This repo can be used to deploy a data science infrastructure in Azure using Terraform, Cloud-Init, and Ansible.

Currently, this Terraform configuration deploys the following resources to Azure:

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

## Dependencies

- HashiCorp [Terraform](https://www.terraform.io/downloads.html)
  - Version >= v0.13.4
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
├── modules
│   ├── README.md
│   ├── mod-azure-datasci-containers
│   ├── mod-azure-datasci-eventhubs
│   ├── mod-azure-datasci-fact-table
│   ├── mod-azure-datasci-grafana
│   ├── mod-azure-datasci-nodes
│   ├── mod-azure-datasci-reverse-proxy
│   └── mod-azure-datasci-status-monitor
├── providers
│   ├── application_stack
│   │   ├── backend.tf
│   │   ├── data.tf
│   │   ├── datasci_containers.tf
│   │   ├── datasci_nodes.tf
│   │   ├── eventhubs.tf
│   │   ├── fact_table.tf
│   │   ├── grafana.tf
│   │   ├── providers_override.tf
│   │   ├── required_provider.tf
│   │   ├── reverse_proxy.tf
│   │   ├── status_monitor.tf
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

The Data Science deployment is broken into 2 parts, the infrastructure and application stack. Each part maintains it's own Terraform remote state in order to minimize the blast radius of destructive changes.

Ideally, these states will reside outside of the Azure Resource Groups Terraform is managing. To assist with this, another Terraform module is provided under `./terraform/remote-state-boostrap` to create those necessary dependencies.

The high level workflow of deploying the pipeline is a follows:

1. Create Azure storage for remote state
2. Deploy Infrastructure (`./terraform/providers/infrastructure`)
3. Deploy Application Stack (`./terraform/providers/application_stack`)

The `infrastructure` components are broken into resource-defined Terraform files and the `application stack` components are deployed via modules, located in this same repository under `./terraform/modules`. This increases the ability to push changes and modifications without multiple Git repositories and versioning. Note, as the development team or project grows, this methodology is subject to change to enhance protection of the data and integrity of the deployments.

### Ansible/Cloud-Init

To avoid prolonged execution times and minimize `null_resource` call outs as recommended by HashiCorp, all of the Ansible-based provisioning and configuration management is initiated via Cloud-Init. This allows for Ansible changes to be managed and updated outside of the Terraform state.

Cloud-Init and Ansible execution can be reviewed from within the Azure Portal for each Virtual Machine here: `Boot diagnostics` -> `Serial Log`

## Environment Variables

In order to facilitate an automated means of deployment, as well as protect sensitive variables, the following environment variables need to be defined for a successful deployment. In order for Terraform to consume them during any operations, the environment variable must be prefixed with `TF_VAR_<variable_name>`.

```bash
## Set Pipeline Environment Variables
export WORKING_DIR="/opt/repos"
export TF_VAR_environment="dev"
export TF_VAR_cluster_name="datasci"
export TF_VAR_resource_group_name="rg-datasci-dev"
export TF_VAR_tfstate_resource_group_name="rg-datasci-oob"
export TF_VAR_state_container="remote-tfstates"
export TF_VAR_default_tags=$(printf '{"Department"="Engineering","PoC"="Me","Environment"="%s","IaC_Managed"="Yes"}' $(echo ${TF_VAR_environment^^}))
export TF_VAR_alert_topics='["alert_message"]'
export TF_VAR_mqtt_topics='["comma","separated","list"]'
export TF_VAR_mqtt_users='["comma","separated","list"]'
# Azure Account Credentials
export ARM_ENVIRONMENT="public"
export ARM_CLIENT_ID="azure-serviceprincipal-client-id"
export ARM_CLIENT_SECRET="azure-serviceprincipal-secret"
export ARM_SUBSCRIPTION_ID="azure-subscription-id"
export ARM_TENANT_ID="azure-tenant-id"
# Remote State Azure Account Credentials (if in different resource group than assets...and it should be! If not, just source the ARM ENVs)
export TF_VAR_remotestate_client_id="azure-serviceprincipal-client-id"
export TF_VAR_remotestate_client_secret="azure-serviceprincipal-secret"
export TF_VAR_remotestate_subscription_id="${ARM_SUBSCRIPTION_ID}"
export TF_VAR_remotestate_tenant_id="${ARM_TENANT_ID}"
export TF_VAR_remotestate_storage_account_name="tfstatedataacct01"
export TF_VAR_sp_password="${ARM_CLIENT_SECRET}"
```

### Special Environment Variables

In some scenarios, secrets and resources are pre-provisioned by the upstream management team. In these cases, and to prevent unnecessary fallout, a few boolean values are defined to influence Terraform's reach. Currently, there are 2 such use cases: Resource Group and Source IPs.

#### Resource Group

In order to avoid Terraform managing or destroying the Azure Resource Group for the pipeline, the variable `manage_resource_group` is set to `False` by default. This prevents Terraform from attempting to manage the parent resource group. So long as the `resource_group_name` variable is defined and the operating account has access, this doesn't affect the functionality of the pipeline deployment.

#### Azure Key Vault

In order to enhance the security of the pipeline, by default Terraform will determine the local workstation IP and pass that as the only "source address" that can reach the Data Science environment.

To complement this feature within a shared state and automation, Azure Key Vault lookups were added. The default behavior is to simply `curl https://ipecho.net/plain` and add that IP as the source.

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

On the Azure Key Vault side, the `azure_keyvault_secret1` secret is expected to be in a comma separated value format: `1.1.1.1,2.2.2.2,3.3.3.3`. If it is not, Terraform will have parsing errors.

## Execution

- With the appropriate variables set, execute this command to deploy the infrastructure:

  ```bash
  cd ${WORKING_DIR}/data-science/terraform/providers/infrastructure:
  terraform init \
    -backend-config="key=${TF_VAR_environment}/$(basename $(pwd)).tfstate" \
    -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group_name}" \
    -backend-config="storage_account_name=${TF_VAR_remotestate_storage_account_name}" \
    -backend-config="container_name=${TF_VAR_state_container}" \
    -backend-config="client_id=${TF_VAR_remotestate_client_id}" \
    -backend-config="client_secret=${TF_VAR_remotestate_client_secret}" \
    -backend-config="subscription_id=${TF_VAR_remotestate_subscription_id}" \
    -backend-config="tenant_id=${TF_VAR_remotestate_tenant_id}"
  terraform plan
  terraform apply
  ```

- Execute this command to deploy the applcation stack:

  ```bash
  cd ${WORKING_DIR}/data-science/terraform/providers/application_stack
  terraform init \
    -backend-config="key=${TF_VAR_environment}/$(basename $(pwd)).tfstate" \
    -backend-config="resource_group_name=${TF_VAR_tfstate_resource_group_name}" \
    -backend-config="storage_account_name=${TF_VAR_remotestate_storage_account_name}" \
    -backend-config="container_name=${TF_VAR_state_container}" \
    -backend-config="client_id=${TF_VAR_remotestate_client_id}" \
    -backend-config="client_secret=${TF_VAR_remotestate_client_secret}" \
    -backend-config="subscription_id=${TF_VAR_remotestate_subscription_id}" \
    -backend-config="tenant_id=${TF_VAR_remotestate_tenant_id}"
  terraform plan
  terraform apply
  ```

- Once deployed, the outputs below will assist in accessing or managing the environment:

  ```bash
  terraform -chdir=${WORKING_DIR}/data-science/terraform/providers/infrastructure output -json | jq -r '.automation_account_ssh_private.value'
  terraform -chdir=${WORKING_DIR}/data-science/terraform/providers/application_stack output -json |jq -r '.datasci_node_public_ips.value'
  terraform -chdir=${WORKING_DIR}/data-science/terraform/providers/application_stack output -json |jq -r '.grafana_admin_password.value.result'
  ```

## Destruction

Destruction of assets will not be an automated process. Tread with caution, as this is permanent and **WILL** result in data loss.

To remove an environment:

1. Infrastructure: `terraform -chdir=${WORKING_DIR}/data-science/terraform/providers/infrastructure destroy`
2. Application Stack: `terraform -chdir=${WORKING_DIR}/data-science/terraform/providers/application_stack destroy`

NOTE: Based on the Terraform bootstrap process, running this destroy **WILL NOT** remove the Terraform state data or storage container, as that is (and should be) provisioned outside of the main infrastructure states to ensure environment safety.

## Operations

After the environment is deployed and SSH access is needed into the nodes, these are couple sample commands that can help access various services:

```bash
#
CONSUL='8500'
PROMETHEUS='9090'
PROMETHEUS_IP='xxx.xxx.xxx.xxx'
ssh -L $CONSUL:localhost:$CONSUL -L $PROMETHEUS:$PROMETHEUS_IP:$PROMETHEUS -i /path/to/terraform_gen_pubkey admin_username@xxx.xxx.xxx.xxx
```
