# Kubernetes Cluster Setup

In HyperledgerLab2, a Hyperledger Fabric network is installed on a Kubernetes cluster. In this step, a Kubernetes cluster is installed on an Openstack cluster.

To achieve this, we need to:

1.  Create resources on the OpenStack cluster. Automation tool used: [Terraform](https://github.com/hashicorp/terraform).
    - TODO few words about terraform
2.  Install the Kubernetes cluster on these resources. Automation tool used: [kubespray](https://github.com/kubernetes-sigs/kubespray).
    - TODO few words about kubespray

## Installed versions

- Kubernetes: `v1.20.4`
- Docker: `20.10.7`

**Code location**:

- [`kubespray/`](../kubespray): it contains the code for external module "kubespray"
- [`terraform/`](../terraform/): terraform configuration files for infrastructure provisioning automation.

## Create Infrastructure and install Kubernetes cluster

**script:** [`scripts/k8s_setup.sh`](../scripts/k8s_setup.sh)

**Variables:**

- [`terraform/clouds.yaml`](../terraform/clouds.yaml)
- [`terraform/cluster.tfvars`](../terraform/cluster.tfvars)

**How it works ?**

Running the script results in creating resources on the OpenStack cluster. The latter is used as an infrastructure to install the Kubernetes cluster.

The script will perform the following steps:

1. Call the script [`scripts/env_setup.sh`](../scripts/env_setup.sh) to install necessary tools andd resources on CLI (versions are defined at the top of the script):
   - Update the submodule code: kubespray
   - Setup python3 environment and install kubespray requirements
   - Generates RSA keys if do not exist that later will be used o ssh into Kubernetes instances.
   - Install docker
   - Install fabric binaries
   - Install yq: a lightweight and portable command-line YAML processor.
   - Install terraform
   - Install kubectl: The Kubernetes command-line tool
   - Install Helm: The package manager for Kubernetes
   - Install jq: a lightweight and flexible command-line JSON processor.
   - Install argo cli: The workflow engine for Kubernetes
2. Setup Openstack instances for k8s nodes using Terraform in two steps:
   - First, `terraform init` to install the required plugins and requirements defined in `versions.tf` files.
   - Second, `terraform apply -var-file=./cluster.tfvars -auto-approve` to accept changes and apply them against the infrastructure. With the motivation to minimize manual intervention when deploying the Hyperledger Fabric network as much as possible, we use `-auto-approve` otherwise terraform will wait for explicit confirmation of changes from the user.
3. Intentionally idle for 90 seconds until instances have an active status and their IP addresses are reachable.
4. Setup a Kubernetes cluster using kubespray
