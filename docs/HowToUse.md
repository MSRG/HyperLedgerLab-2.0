## **Quickstart Guide**

This quickstart will guide you ....

1. Create an instance "CLI" that will be an access point to the Kubernetes cluster.

   - ~/.ssh/id_rsa.pub

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
   - Run Command: `./scripts/k8s_setup.sh`
   - Estimated execution time:
   - Workflow:

   0. will install the required tools
   1. provision infractructure on OpenStack cluster using Terraform
   2. Waiting 60 seconds for Openstack instances to boot
   3. Installing Kubernetes using KubeSpray
   4. Configure Kubectl on the current CLI instance

   - Check for running Kubernetes cluster and good configuation of kubectl by running `kubectl version`.
     You should see a similar output:

   ```
   Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.0", GitCommit:"cb303e613a121a29364f75cc67d3d580833a7479", GitTreeState:"clean", BuildDate:"2021-04-08T16:31:21Z", GoVersion:"go1.16.1", Compiler:"gc", Platform:"linux/amd64"}
   Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:03:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
   ```

5. Installing Hyperledger Fabric on the running Kubernetes cluster:

   - The main Hyperledger Fabric components are defined in a Helm chart for Kubernetes.
   - The by default values of the HLF network configuration are in [./hyperledgerFabric/hlf-kube/values.yaml](../hyperledgerFabric/hlf-kube/values.yaml)
   - In order to have seperate test network configutations, the by default values can be overriden. For example a confirguation with raft as orderer and with tls enabled can be found in [./hyperledgerFabric/raft-tls](../hyperledgerFabric/raft-tls).
     The folder typically contains the following configuration files:

     - [./hyperledgerFabric/raft-tls/configtx.yaml](../hyperledgerFabric/raft-tls/configtx.yaml) that contains the information that is required to build the channel configuration.
       Other information about this configuration file can be found in the official documentation of Hyperledger Fabric https://hyperledger-fabric.readthedocs.io/en/release-2.2/create_channel/create_channel_config.html
     - [./hyperledgerFabric/raft-tls/crypto-config.yaml](../hyperledgerFabric/raft-tls/crypto-config.yaml) that contains the definition of organizations managing orderer nodes and the definition of organizations managing peer nodes.

     - Two different ways of passing variable values when installing helm charts.

     1. yaml files can be passed as arguements. The varialble value in the file on the most right will be used.
        e.g. helm install hlf-kube ./hlf-kube/ -f raft-no-tls/network.yaml -f raft-no-tls/crypto-config.yaml
