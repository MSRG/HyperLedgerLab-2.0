## **Quickstart Guide**

This quickstart will walk you through all the steps to run HyperledgerLab II.
After completing all the steps in this tutorial, a highly configurable Heyperledger Fabric network will be running on a Kubernetes cluster and a report of a bechmarking tool: Hyperledger Caliper evaluating the Heyperledger Fabric network will be generated.

1. Create a a key pair

   - Run Command: `ssh-keygen -t rsa -f ~/.ssh/id_rsa`
   - Import the key pair to Openstack
     - Go to https://openstack.msrg.in.tum.de/horizon/project/access_and_security/
     - Under "Key Pairs" tab click on "Import key pair" and follow the instructions.

2. Create an instance "CLI" that will be an access point to the Kubernetes cluster

   - Security group rules needed to ssh into the CLI instance:

     | Direction | IP Protocol | Ethertype | IP Range  | Port Range | Remote Security Group |
     | --------- | :---------: | :-------: | :-------: | :--------: | :-------------------: |
     | Egress    |     tcp     |   IPv4    | 0.0.0.0/0 |    any     |         None          |
     | Ingress   |     tcp     |   IPv4    | 0.0.0.0/0 |  22 (SSH)  |         None          |

   - To create a security group via the Openstack Dashboard, go the Compute > Access&Security then under "Security Groups" tab create a security group or modify the existing default security group. Next, you need to click on "MANAGE RULES" and add the rules in the table above.
     - The first rule can be simply added by selecting "All TCP" under "Rule" and "Egress" under "Direction".
     - The second rule can be added by selecting "SSH" under "Rules".
   - No additional security group rules is required. The security group creation for the Kubernetes cluster will be handled later by Terraform.

   - To lunch the CLI instance, go to Compute > Instances then click on "LAUNCH INSTANCE". The following are the instance configuration under which HyperledgerLab II was tested. If a configuration is not mentioned then please keep the by default configuration.
     - **Instance Name:** "CLI" or any other name.
     - **Availability Zone:** kvm-hdd
     - **Source:** kvm-ubuntu-focal
     - **Flavor:** m1.large
     - **Security Groups:** select the security group created.
     - **Key Pair:** select the key pair created.

- After launching the instance, wait approximately 90 seconds until the instance has the active status and the IP address is reachable.

- From now on, all the commands are executed from CLI
  - `ssh -i ~/.ssh/id_rsa ubuntu@<instance_ip>`

3. Clone the repository

   ```
   git clone --recursive https://gitlab.lrz.de/ga32nac/hyperledgerlab2.git
   cd hyperledgerlab2
   ```

4. Add OpenStack authentication details

   - Create `clouds.yaml` file under [./terraform](../terraform) folder using [./terraform/sample_clouds.yaml](./terraform/sample_clouds.yaml) as a template and fill it out with details about OpenStack authentication.
   - Data that need to be changed are **username**, **password**, **project name**, **project id** and **auth url**. These data can be found in the OpenStack Dashboard under Compute > Access&Security then "VIEW CREDENTIALS".

5. Provision infrastructure and setup a Kubernetes cluster

   - Check or edit the infrastructure configuration in [./terraform/cluster.tfvars](../terraform/cluster.tfvars). The configuration variables are described in the table below.

   | Variable                               | Description                                                                                                                   |
   | -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
   | `cluster_name`                         | All OpenStack resources will use the Terraform variable `cluster_name` in their name to make it easier to track.              |
   | `availability_zone`                    | The availability zone that will be used by all the instances.                                                                 |
   | `public_key_path`                      | Path to the public key that is used to access the instances.                                                                  |
   | `image`                                | Image to use for all instances.                                                                                               |
   | `number_of_k8s_masters_no_floating_ip` | Number of master instances, default 1.                                                                                        |
   | `flavor_k8s_master_name`               | Flavor name for master instances. e.g m1.medium, m1.large etc.                                                                |
   | `number_of_k8s_nodes_no_floating_ip`   | Number of worker instances, 2 or more.                                                                                        |
   | `flavor_k8s_node_name`                 | Flavor name for worker instances. e.g m1.medium, m1.large etc.                                                                |
   | `network_name`                         | Network name to be used for all the instances. It can be found under NETWORK > Networks in the OpenStack dashboard.           |
   | `subnet_cidr`                          | Network Address of the subnet associated to the network. It can be found under NETWORK > Networks in the OpenStack dashboard. |
   | `k8s_allowed_remote_ips`               | List of CIDR allowed to initiate a SSH connection.                                                                            |

   - To assign more resources to the Kubernetes cluster, please increase the number of Kubernetes nodes (number_of_k8s_nodes_no_floating_ip). The number of master instances (number_of_k8s_masters_no_floating_ip) does not have to be increased.
   - Run Command: `./scripts/k8s_setup.sh `
   - **Estimated execution time:** 20 minutes
   - What will happen ?

     - Installs the required tools
     - Provisions infrastructure on OpenStack cluster using Terraform
     - Installs Kubernetes using Kubesray
     - Configures Kubectl on the current CLI instance

   - Check for running Kubernetes cluster and for the good configuration of kubectl by running `kubectl version`.
     You should see a similar output:

     ```
     Client Version: version.Info{Major:"1", Minor:"21", GitVersion:"v1.21.0", GitCommit:"cb303e613a121a29364f75cc67d3d580833a7479", GitTreeState:"clean", BuildDate:"2021-04-08T16:31:21Z", GoVersion:"go1.16.1", Compiler:"gc", Platform:"linux/amd64"}
     Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:03:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
     ```

   - To destroy the infrastructure provisoned, hence the Kubernetes cluster
     - Run command: `./scripts/k8s_destroy.sh`

6. Install Hyperledger Fabric on the running Kubernetes cluster

   - The main Hyperledger Fabric components are defined in a Helm chart for Kubernetes.
   - The network configuration can be changed in [./fabric/network-configuration.yaml](../fabric/network-configuration.yaml).
   - What can be changed?

     | Configuration              | description                                                                                                                                                                                    |
     | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
     | Fabric container images    | You can define original or custom fabric and caliper container images                                                                                                                          |
     | Fabric Network Config      | You can define number of orgs, peer per orgs and orderers                                                                                                                                      |
     | Fabric Orderer Type        | Available types are "solo" and "etcdraft"                                                                                                                                                      |
     | State Database             | Otions are "goleveldb", "CouchDB". goleveldb - default state database stored in goleveldb. CouchDB - store state database in CouchDB                                                           |
     | Batch Timeout & Batch Size | Batch Timeout: amount of time to wait before creating a batch & Batch Size: number of messages batched into a block                                                                            |
     | Fabric tls enabled         | Wether TLS is enabled in the whole network                                                                                                                                                     |
     | Channel configuration      | You define the channels and chaincode definitions in the respective channel                                                                                                                    |
     | Logging Level              | Logging severity levels are specified using case-insensitive strings chosen from FATAL, PANIC, ERROR, WARNING, INFO or DEBUG                                                                   |
     | use_docker_credentials     | If true then Kubernetes will pull the images from a private docker account. Please refer to the first point of **Common Errors** section to create the docker credential secret in Kubernetes. |

   - Run command: `./scripts/network_run.sh`
   - What will happen ?

     - Installs the helm chart containing all necessary components of the Hyperledger Fabric network.
       - **Estimated execution time:** 40 seconds
     - Creates channel and join all peers to it
       - **Estimated execution time:** 90 seconds per channel
     - Installs all chaincodes on all peers of the respective channel
       - **Estimated execution time:** 120 seconds per chaincode

   - To delete Hyperledger Fabric network
     - Run command: `./scripts/network_delete.sh` to delete all Kubernetes components used to run the Hyperledger Fabric network.

7. Run Hyperledger Caliper

   - Hyperledger Caliper folder contains the following configuration

     - Network Configuration: automatically generated from the network configurations defined in [./fabric/network-configuration.yaml](../fabric/network-configuration.yaml).
     - Workload module and benchmark configuration files should be found in a folder with the respective chaincode name under [./caliper/benchmarks](../caliper/benchmarks).

   - Before running Hyperledger Caliper:

     - Create a git repository to save the generated report.html and the caliper logs.
     - Create a project access token for the project by following this [Gitlab tutorial](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html#creating-a-project-access-token).
     - Following [./caliper/git_sample.yaml](../caliper/git_sample.yaml) as a template, create a [./caliper/git.yaml](../caliper/git.yaml) file where you put information about the git repository just created.

   - Run Hyperledger Caliper

     - Run command: `./scripts/caliper_run.sh <chaincode_folder> ` e.g `./scripts/caliper_run.sh fabcar`
     - Workflow:

       - Runs mosquitto: a lightweight open source message broker that Implements MQTT protocol to carry out messaging between caliper manager and worker(s).
       - Adds the workload Module, Benchmark configuration and Network Configuration as configmap.
       - Runs Caliper Manager
       - Runs Caliper Worker(s)
       - Logs into caliper manager pod

     - **Estimated execution time:** It depends of the actual workload: how many workers, rounds, transactions etc. Nevertheless, the approximate time until the start of the test rounds is 180 seconds.
     - Caliper logs and the report generated are pushed to the git repository under the respective timestamped folder.
     - To log in to the Caliper Manager to view the Caliper report or to one Caliper Worker to investigate a failed transaction:
       1. `kubectl get po`
       2. Copy the pod name of the Caliper Manager or one of the Caliper Workers
       3. `Kubectl logs -f <caliper_pod_name>`

   - To delete Hyperledger caliper:
     - Run command: `./scripts/caliper_delete.sh` to delete all Kubernetes components used to run caliper.

## **Troubleshooting**

1. **Issue:** ErrImagePull: rpc error: code = Unknown desc = Error response from daemon: toomanyrequests: You have reached your pull rate limit. You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limit <br />
   **Explanation:** Docker introduced a pull rate limit. For anonymous usage, the rate limit is fixed to 100 container image requests per six hours, and for free Docker accounts 200 container image requests per six hours. For paid docker account there is however no limit. <br />
   **Workaround** To mitigate the issue, you can login into you free or paid docker account. To do so you need to create a Kubernetes secret based on existing Docker credentials. A Kubernetes cluster uses the Secret of kubernetes.io/dockerconfigjson type to authenticate with a container registry to pull a private image. Please enter this command

   ```
   kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v2/ \ --docker-username=<username> --docker-password=<docker-password> \ --docker-email=<docker-email>
   ```

   Then in [./fabric/network-configuration.yaml](../fabric/network-configuration.yaml), you should set `use_docker_credentials` to `true`.

2. **Issue:** Using kubectl you get "The connection to the server 172.24.35.65:6443 was refused - did you specify the right host or port?" <br />
   **Explanation:** This error indicates that kubectl is not configured to point to the installed Kubernetes cluster. The ansible playbook mentioned in the workaround will solve the problem. <br />
   **Workaround:** from [./terraform](../terraform), run the command `ansible-playbook -i hosts ../playbook.yaml`

3. **Issue:** Error: Error waiting for instance (23bde629-afb5-4c09-a6bc-8ad99aee2d6e) to become ready: unexpected state 'ERROR', wanted target 'ACTIVE'. last error: %!s(<nil>)
   <br />
   **Explanation:** One possible cause of this issue is that no enough resources on the OpenStack project are found to create one or more instances.<br />
   **Workaround:** Go to OpenStack dashboard to check the error message. Normally, this problem is not related to HyperledgerLab2.

4. **Issue:** Error: Unable to create openstack_compute_keypair_v2 kubernetes-hll: Expected HTTP response code [200 201] when accessing [POST http://172.24.18.142:8774/v2.1/13291ac9bdb64f44ab84a01d319dd9fb/os-keypairs], but got 409 instead
   │ {"conflictingRequest": {"message": "Key pair 'kubernetes-hll' already exists.", "code": 409}} <br />
   **Explanation:** You are trying the create a new Kubernetes cluster in the same Openstack project using the same cluster name.<br />
   **Workaround:** In [./terraform/cluster.tfvars](../terraform/cluster.tfvars), enter a different cluster name than the cluster running in your Openstack project.
