# Data Science Infrastructure Deployment
This repo can be used to deploy a data science infrastructure in Azure using Terraform and Ansible.

Currently, this Terraform configuration deploys the following resources to Azure
- A Resource Group
- A Virtual Network
- A Subnet
- A Network Security Group
- A storage account for boot diagnostics
- An IoT Hub
- An Event Hub
- An Azure data lake storage container
- A Mosquitto MQTT Broker in a Docker Container
- A VM with Apache Spark, and Jupyter Notebook

## Table of Contents
* [Initial Setup](#initial-setup)
* [Run the Terraform Deployment](#run-the-terraform-deployment)

### Code Editing
Any IDE or text editor can be used to work with the code in this repo, but it is recommended to use Visual Studio Code
1. [Install VS Code](https://code.visualstudio.com/)
1. Install the following two Terraform Extensions for VS Code
    1. [Azure Terraform](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
    1. [Terraform](https://marketplace.visualstudio.com/items?itemName=mauve.terraform)

## Initial Setup
### Setup a Development environment 
If running on Windows, it is recommended to setup a Linux VM to do all the development and deployment from. The development
environment provides a local (i.e without Azure) environment in which unit and integration testing is available.  Use the steps 
below to create a Ubuntu VM with Vagrant.

1. Clone this repo
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. [Install vagrant](https://www.vagrantup.com/downloads.html)
1. `vagrant plugin install vagrant-vbguest`
1. `vagrant plugin install vagrant-disksize`
1. `vagrant up` from  bash/Powershell to create and boot the VM
    1. Note: this may take a long time to complete (> 1h). If desktop environment isn't needed, comment out these lines in the Vagrantfile script and save a lot of time
        1. `config.vm.provision "shell", inline: "sudo apt-get --assume-yes install ubuntu-desktop"` and 
        1. `config.vm.provision :shell, path: "bootstrap.sh"`
    1. Restart with `vagrant reload --provision` in case of failures (will require at least a few reloads)
1. login to the VM, `username=vagrant, pass=vagrant`


### (Optional) Manual setup
If running on macOS or Linux natively, the step of creating a dedicated VM can be skipped. However, it will be necessary to setup
the development and testing environment manually on your host machine. 

### Create an SSH Key Pair
An SSH key pair is needed to provision any machine with SSH access.  When creating a cluster using this terraform configuration, 
any VMs will have their [authorized_keys](https://www.ssh.com/ssh/authorized_keys) file updated to include your public key 
so that you can SSH into the server.

If you already have created a default SSH key, then you can skip creating a new SSH key pair.

#### Create a new SSH key pair
Detailed instructions can be found [here](https://confluence.atlassian.com/bitbucketserver/creating-ssh-keys-776639788.html)
1. `ssh-keygen -C ""`

### Install Terraform

#### Linux
1. `sudo apt install unzip`
1. download the binary from terraform.io/downloads.html
1. `unzip terraform_0.12.20_linux_amd64.zip`
1. `sudo mv terraform /usr/local/bin`

#### macOS
1. [Install brew](https://brew.sh/)
1. `brew install terraform`

##### Test Terraform

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


### Install Azure CLI

#### Linux
1. `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`

#### macOS
[Detailed instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest)
1. `brew update && brew install azure-cli`

#### Try it
1. `az cloud set --name AzureUSGovernment`
1. `az login`
1. You'll see output similar to this  
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
1. `az account set --subscription="07c2619d-xxxx-xxxx-xxxx-xxxxxxxxxxxx"`, but use the actual ID from above


### Install Ansible

#### Linux
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
1. Install pip, `sudo apt install python-pip`
1. `pip install ansible[azure]`
1. Disable host checking by uncommenting `host_key_checking = False` under `/etc/ansible/ansible.conf`

#### macOS
1. `brew install ansible`
1. `pip3 install 'ansible[azure]'`
1. To verify, run `ansible --version`
1. Disable host checking by uncommenting `host_key_checking = False` under `/usr/local/etc/ansible/ansible.conf`


## Run the Terraform Deployment
1. `cd provision-datasci`
1. `terraform init`
1. `terraform apply datasci.tf -var-file=datasci_vars.tfvars`
1. Log into the azure portal and observe the resources created

### Verify local data-science VM(s) Setup
1. Check Zookeeper: 
    1. `telnet localhost 2181`
    1. `ruok`
    1. should receive `imok` response
1. Check Kafka
    1. in first terminal, add message `/usr/local/kafka/bin/kafka-console-producer.sh --broker-list locahost:9092 --topic IoTHub` (or skip if you're sending messages from Android NS app)
    1. type in a message or two and close the producer console with Ctrl-D (or skip this step if you're sending messages from the Android NS app)
    1. in second terminal, start consumer: `/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic IoTHub --from-beginning  --partition 0`


### To open a Jupyter notebook on one of the nodes
 1. Note the output printed by ansible from the above command. It should look similar to this.
    ```
    TASK [notebook : debug] ********************************************************
    ok: [datasci-dev0.usgovarizona.cloudapp.usgovcloudapi.net] => {
        "out.stderr_lines": [
            "[I 21:45:23.470 NotebookApp] Serving notebooks from local directory: /home/datasci_admin", 
            "[I 21:45:23.470 NotebookApp] The Jupyter Notebook is running at:", 
            "[I 21:45:23.471 NotebookApp] http://localhost:8888/?token=c153e52cb3c6ad4a5368df00cd8fe4f6116c35f48152fd08", 
            "[I 21:45:23.471 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).", 
            "[C 21:45:23.474 NotebookApp] ", 
    ```
1. Setup ssh port forwarding for port 8888 when working with the Azure vm (which is the default port used by Jupyter notebook server)
    ```
    ssh -N -f -L localhost:8888:localhost:8888 datasci_admin@datasci-dev0.usgovarizona.cloudapp.usgovcloudapi.net
   ```
1. Open the url from step 1 (i.e http://localhost:8888/?token=c153e52cb3c6ad4a5368df00cd8fe4f6116c35f48152fd08") in a browser on localhost   


## (Optional) Tear down the Azure Deployment
1. To tear down the allocations, run `terraform destroy -var-file=datasci_vars.tfvars`.
