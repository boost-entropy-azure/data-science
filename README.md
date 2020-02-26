## Set up

#### Install Terraform

1. `sudo apt install unzip`
2. download the binary from terraform.io/downloads.html
3. `unzip terraform_0.12.20_linux_amd64.zip`
4. `sudo mv terraform /usr/local/bin`

###### Test terraform

```
dino@twofatcheeks:~$ terraform
Usage: terraform [-version] [-help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
```

#### Install Azure CLI

###### Download and Install
`curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

###### Try it
1. `az cloud set --name AzureUSGovernment`
2. `az login`
3. You'll see output similar to this  
    ```
    [
      {
        "cloudName": "AzureUSGovernment",
        "homeTenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "id": "07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "isDefault": true,
        "managedByTenants": [],
        "name": "Azure subscription 1",
        "state": "Enabled",
        "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "user": {
          "name": "dtufekcic@cti.onmicrosoft.us",
          "type": "user"
        }
      }
    ]
    ```
4. `az account set --subscription="07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`, but use the actual ID from above

###### Provision a Virtual Machine
1. `cd provision-datasci`
1. `terraform init`
1. Generate an SSH key pair: `ssh-keygen -C ""`
1. copy the public SSH key into [terraform script](provision-datasci/datasci.tf)
1. `terraform plan -var-file=datasci_vars.tfvars  -out plan.tf`
1. if all goes well, you can apply the plan by running `terraform apply plan.tf` and wait
    ```
    azurerm_virtual_machine.datasci_dev01: Creating...
    azurerm_virtual_machine.datasci_dev01: Still creating... [10s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [20s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [30s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [40s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [50s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [1m0s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [1m10s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [1m20s elapsed]
    azurerm_virtual_machine.datasci_dev01: Still creating... [1m30s elapsed]
    azurerm_virtual_machine.datasci_dev01: Creation complete after 1m34s [id=/subscriptions/07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/development/providers/Microsoft.Compute/virtualMachines/datasci_dev01]
    
    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
    dino@twofatcheeks:~/sandbox/data-science$
    ```
1. log into the azure portal and observe the resources created above
1. to tear down the allocations, run `terraform destroy -var-file=datasci_vars.tfvars`. Eventually you should see the following
    ```
    azurerm_resource_group.datasci_dev_group: Still destroying... [id=/subscriptions/07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/development, 2m0s elapsed]
    azurerm_resource_group.datasci_dev_group: Still destroying... [id=/subscriptions/07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/development, 2m10s elapsed]
    azurerm_resource_group.datasci_dev_group: Still destroying... [id=/subscriptions/07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/development, 2m20s elapsed]
    azurerm_resource_group.datasci_dev_group: Still destroying... [id=/subscriptions/07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/development, 2m30s elapsed]
    azurerm_resource_group.datasci_dev_group: Still destroying... [id=/subscriptions/07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/development, 2m40s elapsed]
    azurerm_resource_group.datasci_dev_group: Destruction complete after 2m48s
    
    Destroy complete! Resources: 8 destroyed.
    dino@twofatcheeks:~/sandbox/datasci$
    ```
1. The above script will create a set of Virtual Machines. We'll need the machine's IPs in order to deploy kafka to all 
of them. To get the public IP from Azure, run
    `az vm show --resource-group datasci_dev_group --name datasci_dev0 -d --query [publicIps] --o tsv`
    
#### Install Ansible
1. `sudo apt-add-repository --yes --update ppa:ansible/ansible`
1. `sudo apt install ansible`
1. To verify, run `ansible --version`. You should see output similar to this:
    ```
        ansible 2.9.4
         config file = /etc/ansible/ansible.cfg
         configured module search path = [u'/home/dino/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
         ansible python module location = /usr/lib/python2.7/dist-packages/ansible
         executable location = /usr/bin/ansible
         python version = 2.7.17 (default, Nov  7 2019, 10:07:09) [GCC 7.4.0]
    ```
1. Install pip, `sudo apt install python-pip
1. `pip install ansible[azure]`

###### Run ansible-kafka playbook 
1. `cd ../configure-datasci`
1. `ansible-playbook -i inventory.ini datasci_play.yml`

    **NOTE:
        If you destroyed the datasci environment and are rebuilding it, you have to remove the datasci node 
        information from ~/.ssh/known_hosts in order to avoid 'WARNING: POSSIBLE DNS SPOOFING DETECTED!' warnings from SSH.
        Also, it helps to manually connect to datasci-\* nodes with ssh so proper keys are exchanged with new machines.**
1. 
##