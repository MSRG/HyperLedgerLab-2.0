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
   The main Hyperledger Fabric components are defined in a Helm chart for Kubernetes.
   helm install hlf-kube ./hlf-kube/ -f raft-no-tls/network.yaml -f raft-no-tls/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false --set orderer.cluster.enabled=true

   or change values in values.yaml
   helm upgrade hlf-kube ./hlf-kube/ -f raft-no-tls/network.yaml -f raft-no-tls/crypto-config.yaml --set peer.launchPods=false --set orderer.launchPods=false --set orderer.cluster.enabled=true

   -
