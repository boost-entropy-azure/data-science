#### Setup a development VM
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

#### Deploy data_science project to Azure
- Note: On the newly provisioned VM steps 1 through 4 have already been completed by Vagrant.
1. Clone this repo
1. Install Ansible
    - `sudo apt-add-repository --yes --update ppa:ansible/ansible`
    - `sudo apt install ansible`
1. Install Terraform
    - `sudo apt install unzip`
    - download the binary from terraform.io/downloads.html
    - `unzip terraform_0.12.20_linux_amd64.zip`
    - `sudo mv terraform /usr/local/bin`
1. Install Azure CLI
    - `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
1. Configure Azure CLI (only needed if provisioning Azure resources)
    1. `az cloud set --name AzureUSGovernment`
    1. `az login`
    1. You'll see output similar to this after you login through your web browser
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
1. Provision data_science project on Azure (only needed if provisioning Azure resources)
    1. `cd provision-datasci`
    1. Generate an SSH key pair: `ssh-keygen -C ""`
    1. `terraform init`
    1. `terraform apply datasci.tf -var-file=datasci_vars.tfvars`
    1. log into the azure portal and observe the resources created above
        1. to tear down the allocations, run `terraform destroy -var-file=datasci_vars.tfvars`. Eventually you should see the following
    1. The above script will create a set of Virtual Machines

#### Verify vm(s) setup
1. ssh to the Azure vm (skip this step if checking the local vm)
    1. `ssh datasci_admin@datasci-dev0.usgovarizona.cloudapp.usgovcloudapi.net`
1. check zookeeper: 
    1. `telnet localhost 2181`
    1. `ruok`
    1. should receive `imok` response
1. check kafka
    1. in first terminal, add message `/usr/local/kafka/bin/kafka-console-producer.sh --broker-list locahost:9092 --topic IoTHub` (or skip if you're sending messages from Android NS app)
    1. type in a message or two and close the producer console with Ctrl-D (or skip this step if you're sending messages from the Android NS app)
    1. in second terminal, start consumer: `/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic IoTHub --from-beginning  --partition 0`
1. On local VM, disable Ansible's host checking (optional but helps with re-created Azure vms)
    - Uncomment `host_key_checking = False` under `/etc/ansible/ansible.conf`
        
###### To open a Jupyter notebook on one of the nodes
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