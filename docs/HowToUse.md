## **Quickstart Guide**

This quickstart will guide you ....

0. Create a a key pair

   - Run Command: `ssh-keygen -t rsa -f ~/.ssh/id_rsa`
   - Import the key pair to Openstack
     - Go to https://openstack.msrg.in.tum.de/horizon/project/access_and_security/
     - Under "Key Pairs" tab click on "Import key pair" and follow the instructions

1. Create an instance "CLI" that will be an access point to the Kubernetes cluster.

   - Security group rules needed to ssh into the CLI instance:

     | Direction | IP Protocol | Ethertype | IP Range  | Port Range | Remote Security Group |
     | --------- | :---------: | :-------: | :-------: | :--------: | :-------------------: |
     | Egress    |     any     |   IPv4    | 0.0.0.0/0 |            |         None          |
     | Egress    |    icmp     |   IPv4    | 0.0.0.0/0 |            |         None          |
     | Ingress   |     tcp     |   IPv4    | 0.0.0.0/0 |  22 (SSH)  |         None          |

   - No aditional security group rules is required. The security group creation for the kubernetes cluster will be handled later by Terraform.

   - From the host machine, we want to copy the private key to CLI, the latter will be used later to provision other instances.
     `scp -i ~/.ssh/id_rsa ~/.ssh/id_rsa ubuntu@<instance_ip>:/home/ubuntu/.ssh/id_rsa`
   - The rest of this tutorial are executed from CLI: `ssh -i ~/.ssh/id_rsa ubuntu@<instance_ip>`

2. Clone the repository:

   ```
   git clone --recursive https://gitlab.lrz.de/ga32nac/hyperledgerlab2.git
   cd hyperledgerlab2
   ```

3. Add OpenStack authentication details:

   - Create `clouds.yaml` file under [./terraform](../terraform) folder following [./terraform/sample_clouds.yaml](./terraform/sample_clouds.yaml) and fill it out with details about OpenStack authentication.
     - PS: if you change the by default cloud name "mycloud", then change it also in [versions.tf](versions.tf)

4. Provision infrastrucutre and setup a kubernetes cluster

   - Check or edit the infrastruce configuration in [./terraform/cluster.tfvars](../terraform/cluster.tfvars)
   - Check or edit many kubernetes configuations in [./terraform/inventory/group_vars](../terraform/inventory/group_vars)
   - Run Command: `./scripts/k8s_setup.sh `
   - Workflow:

     - Installs the required tools
     - Provisions infractructure on OpenStack cluster using Terraform
     - Installs Kubernetes using Kubesray
     - Configures Kubectl on the current CLI instance

   - Check for running Kubernetes cluster and good configuation of kubectl by running `kubectl version`.
     You should see a similar output:

     ```
     Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.0", GitCommit:"cb303e613a121a29364f75cc67d3d580833a7479", GitTreeState:"clean", BuildDate:"2021-04-08T16:31:21Z", GoVersion:"go1.16.1", Compiler:"gc", Platform:"linux/amd64"}
     Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:03:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
     ```

   - To destroy the infrastructure provisoned, hence the kubernetes cluster:
     - Run command: `./script/k8s_destroy.sh`

5. Install Hyperledger Fabric on the running Kubernetes cluster:

   - The main Hyperledger Fabric components are defined in a Helm chart for Kubernetes.
   - The by default values of the HLF network configuration are in [./hyperledgerFabric/hlf-kube/values.yaml](../hyperledgerFabric/hlf-kube/values.yaml)
   - In order to have seperate test network configutations, the by default values can be overriden. For example a confirguation with raft as orderer and with tls enabled can be found in [./hyperledgerFabric/raft-tls](../hyperledgerFabric/raft-tls).
     The folder typically contains the following configuration files:

     - [./hyperledgerFabric/raft-tls/configtx.yaml](../hyperledgerFabric/raft-tls/configtx.yaml) contains the information that is required to build the channel configuration.
     - [./hyperledgerFabric/raft-tls/crypto-config.yaml](../hyperledgerFabric/raft-tls/crypto-config.yaml) contains the definition of organizations managing orderer nodes and the definition of organizations managing peer nodes.
     - [./hyperledgerFabric/raft-tls/network.yaml](../hyperledgerFabric/raft-tls/network.yaml) contains the network definition.

   - Install the configuered network on the running Kubenetes cluster:

     - Run command: `./script/network_run.sh <configuration_folder>` e.g `./script/network_run.sh raft-tls`
     - Estimated execution time:

     - Workflow:

       - Create necessary stuff for the chart installation.
       - Installs the helm chart
       - Installs channel
       - Insalls chaincode
       - more details ?

   - To delete Hyperledger Fabric network:
     - Run command: `./script/network_delete.sh` to delete all kubernetes components used to run the Hyperledger Fabric network.

6. Run Hyperledger Caliper:

   - Hyperledger Caliper folder contains the following configuration:

     - workload Module
     - Benchmark configuration
     - Network Configuration: two network configurations can be found in [./hyperledgerCaliper/networks/](../hyperledgerCaliper/networks/): one network configruation with TLS and without TLS enabled.

     Workload module and benchmark configuration are chaincode related configuration. Both files can be found in a folder with the respective chaincode name.

   - Run Hyperledger Caliper:

     - Run command: `./script/caliper_run.sh <chaincode_folder> <network_configuration_folder>` e.g `./script/caliper_run.sh asset-transfer-basic tls`
     - Workflow:

       - Runs mosquitto: a lightweight open source message broker that Implements MQTT protocol to carry out messaging between caliper manager and worker(s).
       - Adds the workload Module, Benchmark configuration and Network Configuration as configmap.
       - Runs Caliper Manager
       - Runs Caliper Worker(s)
       - more details ?

     - Log into caliper manager pod to see the benchamrkig report using the command `kubectl logs -f <caliper_manager_pod_name>`.
       To get the caliper manager pod name you can use the command `kubectl get pods` to get the list of pods.

   - To delete Hyperledger caliper:
     - Run command: `./script/caliper_delete.sh` to delete all kubernetes components used to run caliper.
