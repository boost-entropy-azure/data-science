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
1. Install pip, `sudo apt install python-pip`
1. `pip install ansible[azure]`
1. Disable host checking by uncommenting `host_key_checking = False` under `/etc/ansible/ansible.conf`

###### Provision a Virtual Machine
1. `cd provision-datasci`
1. Generate an SSH key pair: `ssh-keygen -C ""`
1. `terraform init`
1. `terraform apply datasci.tf -var-file=datasci_vars.tfvars`
1. log into the azure portal and observe the resources created above
    1. to tear down the allocations, run `terraform destroy -var-file=datasci_vars.tfvars`. Eventually you should see the following
1. The above script will create a set of Virtual Machines

###### Verify vm is setup correctly
1. ssh to the vm `ssh datasci_admin@datasci-dev0.usgovarizona.cloudapp.usgovcloudapi.net`
1. check zookeeper: 
    1. `telnet localhost 2181`
    1. `ruok`
    1. should receive `imok` response
1. check kafka
    1. in first terminal, add message `/usr/local/kafka/bin/kafka-console-producer.sh --broker-list locahost:9092 --topic IoTHub` (or skip if you're sending messages from Android NS app)
    1. type in a message or two and close the producer console with Ctrl-D (or skip this step if you're sending messages from the Android NS app)
    1. in second terminal, start consumer: `/usr/local/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic IoTHub --from-beginning  --partition 0`
    
######## To open a Jupyter notebook on one of the nodes
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
1. Setup ssh port forwarding for port 8888 (which is the default port used by Jupyter notebook server)
    ```
    ssh -N -f -L localhost:8888:localhost:8888 datasci_admin@datasci-dev0.usgovarizona.cloudapp.usgovcloudapi.net
   ```
1. Open the url from step 1 (i.e http://localhost:8888/?token=c153e52cb3c6ad4a5368df00cd8fe4f6116c35f48152fd08") in a browser on localhost   