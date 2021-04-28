# Kubernetes on OpenStack with Terraform

Provision a Kubernetes cluster with [Terraform](https://www.terraform.io) on
OpenStack.

## Status

This will install a Kubernetes cluster on an OpenStack Cloud. It should work on
most modern installs of OpenStack that support the basic services, MSRG openstack cluster among others.

## Approach

The terraform configuration inspects variables found in
[variables.tf](variables.tf) to create resources in your OpenStack cluster.
There is a [python script](hosts) that reads the generated`.tfstate`
file to generate a dynamic inventory that is consumed by the main ansible script
to actually install kubernetes and stand up the cluster.

## Using an existing network

It is possible to use an existing network instead of creating one. To use an
existing network set the network_id variable to the uuid of the network you wish
to use.

For example:

```ShellSession
network_id = "dd0e99f0-4112-458f-a30f-328b517ed627"
```

## Cluster variables

The construction of the cluster is driven by values found in
[variables.tf](variables.tf).

In [cluster.tfvars](cluster.tfvars) different variables can be edited to override to by default variables in [variables.tf](variables.tf).

## OpenStack access and credentials

No provider variables are hardcoded inside `variables.tf`.
However, you should create a clouds.yaml file following [sample_clouds.yaml](sample_clouds.yaml).

You can get the OpenStack access and credentials in Compute > Access & Security > API Access

If you change the cloud name (mycloud) in clouds.yaml, you need to also change the cloud name in OpenStack Provider configuration located in [versions.tf](versions.tf).

#### Cluster variables

The construction of the cluster is driven by values found in
[variables.tf](variables.tf).

For your cluster, edit `inventory/$CLUSTER/cluster.tfvars`.

| Variable                                                                                | Description                                                                                                                                                                                                    |
| --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cluster_name`                                                                          | All OpenStack resources will use the Terraform variable`cluster_name` (default`example`) in their name to make it easier to track. For example the first compute resource will be named`example-kubernetes-1`. |
| `az_list`                                                                               | List of Availability Zones available in your OpenStack cluster.                                                                                                                                                |
| `network_name`                                                                          | The name to be given to the internal network that will be generated                                                                                                                                            |
| `network_dns_domain`                                                                    | (Optional) The dns_domain for the internal network that will be generated                                                                                                                                      |
| `dns_nameservers`                                                                       | An array of DNS name server names to be used by hosts in the internal subnet.                                                                                                                                  |
| `floatingip_pool`                                                                       | Name of the pool from which floating IPs will be allocated                                                                                                                                                     |
| `k8s_master_fips`                                                                       | A list of floating IPs that you have already pre-allocated; they will be attached to master nodes instead of creating new random floating IPs.                                                                 |
| `external_net`                                                                          | UUID of the external network that will be routed to                                                                                                                                                            |
| `flavor_k8s_master`,`flavor_k8s_node`,`flavor_etcd`, `flavor_bastion`,`flavor_gfs_node` | Flavor depends on your openstack installation, you can get available flavor IDs through `openstack flavor list`                                                                                                |
| `image`,`image_gfs`                                                                     | Name of the image to use in provisioning the compute resources. Should already be loaded into glance.                                                                                                          |
| `ssh_user`,`ssh_user_gfs`                                                               | The username to ssh into the image with. This usually depends on the image you have selected                                                                                                                   |
| `public_key_path`                                                                       | Path on your local workstation to the public key file you wish to use in creating the key pairs                                                                                                                |
| `number_of_k8s_masters`, `number_of_k8s_masters_no_floating_ip`                         | Number of nodes that serve as both master and etcd. These can be provisioned with or without floating IP addresses                                                                                             |
| `number_of_k8s_masters_no_etcd`, `number_of_k8s_masters_no_floating_ip_no_etcd`         | Number of nodes that serve as just master with no etcd. These can be provisioned with or without floating IP addresses                                                                                         |
| `number_of_etcd`                                                                        | Number of pure etcd nodes                                                                                                                                                                                      |
| `number_of_k8s_nodes`, `number_of_k8s_nodes_no_floating_ip`                             | Kubernetes worker nodes. These can be provisioned with or without floating ip addresses.                                                                                                                       |
| `number_of_bastions`                                                                    | Number of bastion hosts to create. Scripts assume this is really just zero or one                                                                                                                              |
| `number_of_gfs_nodes_no_floating_ip`                                                    | Number of gluster servers to provision.                                                                                                                                                                        |
| `gfs_volume_size_in_gb`                                                                 | Size of the non-ephemeral volumes to be attached to store the GlusterFS bricks                                                                                                                                 |
| `supplementary_master_groups`                                                           | To add ansible groups to the masters, such as `kube-node` for tainting them as nodes, empty by default.                                                                                                        |
| `supplementary_node_groups`                                                             | To add ansible groups to the nodes, such as `kube-ingress` for running ingress controller pods, empty by default.                                                                                              |
| `bastion_allowed_remote_ips`                                                            | List of CIDR allowed to initiate a SSH connection, `["0.0.0.0/0"]` by default                                                                                                                                  |
| `master_allowed_remote_ips`                                                             | List of CIDR blocks allowed to initiate an API connection, `["0.0.0.0/0"]` by default                                                                                                                          |
| `k8s_allowed_remote_ips`                                                                | List of CIDR allowed to initiate a SSH connection, empty by default                                                                                                                                            |
| `worker_allowed_ports`                                                                  | List of ports to open on worker nodes, `[{ "protocol" = "tcp", "port_range_min" = 30000, "port_range_max" = 32767, "remote_ip_prefix" = "0.0.0.0/0"}]` by default                                              |
| `master_allowed_ports`                                                                  | List of ports to open on master nodes, expected format is `[{ "protocol" = "tcp", "port_range_min" = 443, "port_range_max" = 443, "remote_ip_prefix" = "0.0.0.0/0"}]`, empty by default                        |
| `wait_for_floatingip`                                                                   | Let Terraform poll the instance until the floating IP has been associated, `false` by default.                                                                                                                 |
| `node_root_volume_size_in_gb`                                                           | Size of the root volume for nodes, 0 to use ephemeral storage                                                                                                                                                  |
| `master_root_volume_size_in_gb`                                                         | Size of the root volume for masters, 0 to use ephemeral storage                                                                                                                                                |
| `gfs_root_volume_size_in_gb`                                                            | Size of the root volume for gluster, 0 to use ephemeral storage                                                                                                                                                |
| `etcd_root_volume_size_in_gb`                                                           | Size of the root volume for etcd nodes, 0 to use ephemeral storage                                                                                                                                             |
| `bastion_root_volume_size_in_gb`                                                        | Size of the root volume for bastions, 0 to use ephemeral storage                                                                                                                                               |
| `use_server_group`                                                                      | Create and use openstack nova servergroups, default: false                                                                                                                                                     |
| `use_access_ip`                                                                         | If 1, nodes with floating IPs will transmit internal cluster traffic via floating IPs; if 0 private IPs will be used instead. Default value is 1.                                                              |
| `k8s_nodes`                                                                             | Map containing worker node definition, see explanation below                                                                                                                                                   |

##### k8s_nodes

Allows a custom defintion of worker nodes giving the operator full control over individual node flavor and
availability zone placement. To enable the use of this mode set the `number_of_k8s_nodes` and
`number_of_k8s_nodes_no_floating_ip` variables to 0. Then define your desired worker node configuration
using the `k8s_nodes` variable.

For example:

```ini
k8s_nodes = {
  "1" = {
    "az" = "sto1"
    "flavor" = "83d8b44a-26a0-4f02-a981-079446926445"
    "floating_ip" = true
  },
  "2" = {
    "az" = "sto2"
    "flavor" = "83d8b44a-26a0-4f02-a981-079446926445"
    "floating_ip" = true
  },
  "3" = {
    "az" = "sto3"
    "flavor" = "83d8b44a-26a0-4f02-a981-079446926445"
    "floating_ip" = true
  }
}
```

Would result in the same configuration as:

```ini
number_of_k8s_nodes = 3
flavor_k8s_node = "83d8b44a-26a0-4f02-a981-079446926445"
az_list = ["sto1", "sto2", "sto3"]
```

And:

```ini
k8s_nodes = {
  "ing-1" = {
    "az" = "sto1"
    "flavor" = "83d8b44a-26a0-4f02-a981-079446926445"
    "floating_ip" = true
  },
  "ing-2" = {
    "az" = "sto2"
    "flavor" = "83d8b44a-26a0-4f02-a981-079446926445"
    "floating_ip" = true
  },
  "ing-3" = {
    "az" = "sto3"
    "flavor" = "83d8b44a-26a0-4f02-a981-079446926445"
    "floating_ip" = true
  },
  "big-1" = {
    "az" = "sto1"
    "flavor" = "3f73fc93-ec61-4808-88df-2580d94c1a9b"
    "floating_ip" = false
  },
  "big-2" = {
    "az" = "sto2"
    "flavor" = "3f73fc93-ec61-4808-88df-2580d94c1a9b"
    "floating_ip" = false
  },
  "big-3" = {
    "az" = "sto3"
    "flavor" = "3f73fc93-ec61-4808-88df-2580d94c1a9b"
    "floating_ip" = false
  },
  "small-1" = {
    "az" = "sto1"
    "flavor" = "7a6a998f-ac7f-4fb8-a534-2175b254f75e"
    "floating_ip" = false
  },
  "small-2" = {
    "az" = "sto2"
    "flavor" = "7a6a998f-ac7f-4fb8-a534-2175b254f75e"
    "floating_ip" = false
  },
  "small-3" = {
    "az" = "sto3"
    "flavor" = "7a6a998f-ac7f-4fb8-a534-2175b254f75e"
    "floating_ip" = false
  }
}
```

Would result in three nodes in each availability zone each with their own separate naming,
flavor and floating ip configuration.

The "schema":

```ini
k8s_nodes = {
  "key | node name suffix, must be unique" = {
    "az" = string
    "flavor" = string
    "floating_ip" = bool
  },
}
```

All values are required.

#### Terraform state files

In the cluster's inventory folder, the following files might be created (either by Terraform
or manually), to prevent you from pushing them accidentally they are in a
`.gitignore` file in the `terraform/openstack` directory :

- `.terraform`
- `.tfvars`
- `.tfstate`
- `.tfstate.backup`

You can still add them manually if you want to.

### Initialization

Before Terraform can operate on your cluster you need to install the required
plugins. This is accomplished as follows:

```ShellSession
cd inventory/$CLUSTER
terraform init ../../contrib/terraform/openstack
```

This should finish fairly quickly telling you Terraform has successfully initialized and loaded necessary modules.

### Provisioning cluster

You can apply the Terraform configuration to your cluster with the following command
issued from your cluster's inventory directory (`inventory/$CLUSTER`):

```ShellSession
terraform apply -var-file=cluster.tfvars ../../contrib/terraform/openstack
```

if you chose to create a bastion host, this script will create
`contrib/terraform/openstack/k8s-cluster.yml` with an ssh command for Ansible to
be able to access your machines tunneling through the bastion's IP address. If
you want to manually handle the ssh tunneling to these machines, please delete
or move that file. If you want to use this, just leave it there, as ansible will
pick it up automatically.

### Destroying cluster

You can destroy your new cluster with the following command issued from the cluster's inventory directory:

```ShellSession
terraform destroy -var-file=cluster.tfvars ../../contrib/terraform/openstack
```

If you've started the Ansible run, it may also be a good idea to do some manual cleanup:

- remove SSH keys from the destroyed cluster from your `~/.ssh/known_hosts` file
- clean up any temporary cache files: `rm /tmp/$CLUSTER-*`

### Debugging

You can enable debugging output from Terraform by setting
`OS_DEBUG` to 1 and`TF_LOG` to`DEBUG` before running the Terraform command.

### Terraform output

Terraform can output values that are useful for configure Neutron/Octavia LBaaS or Cinder persistent volume provisioning as part of your Kubernetes deployment:

- `private_subnet_id`: the subnet where your instances are running is used for `openstack_lbaas_subnet_id`
- `floating_network_id`: the network_id where the floating IP are provisioned is used for `openstack_lbaas_floating_network_id`

## Ansible

### Node access

#### SSH

Ensure your local ssh-agent is running and your ssh key has been added. This
step is required by the terraform provisioner:

```ShellSession
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
```

If you have deployed and destroyed a previous iteration of your cluster, you will need to clear out any stale keys from your SSH "known hosts" file ( `~/.ssh/known_hosts`).

#### Metadata variables

The [python script](../terraform.py) that reads the
generated`.tfstate` file to generate a dynamic inventory recognizes
some variables within a "metadata" block, defined in a "resource"
block (example):

```ini
resource "openstack_compute_instance_v2" "example" {
    ...
    metadata {
        ssh_user = "ubuntu"
        prefer_ipv6 = true
        python_bin = "/usr/bin/python3"
    }
    ...
}
```

As the example shows, these let you define the SSH username for
Ansible, a Python binary which is needed by Ansible if
`/usr/bin/python` doesn't exist, and whether the IPv6 address of the
instance should be preferred over IPv4.

#### Bastion host

Bastion access will be determined by:

- Your choice on the amount of bastion hosts (set by `number_of_bastions` terraform variable).
- The existence of nodes/masters with floating IPs (set by `number_of_k8s_masters`, `number_of_k8s_nodes`, `number_of_k8s_masters_no_etcd` terraform variables).

If you have a bastion host, your ssh traffic will be directly routed through it. This is regardless of whether you have masters/nodes with a floating IP assigned.
If you don't have a bastion host, but at least one of your masters/nodes have a floating IP, then ssh traffic will be tunneled by one of these machines.

So, either a bastion host, or at least master/node with a floating IP are required.

#### Test access

Make sure you can connect to the hosts. Note that Flatcar Container Linux by Kinvolk will have a state `FAILED` due to Python not being present. This is okay, because Python will be installed during bootstrapping, so long as the hosts are not `UNREACHABLE`.

```ShellSession
$ ansible -i inventory/$CLUSTER/hosts -m ping all
example-k8s_node-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
example-etcd-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
example-k8s-master-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

If it fails try to connect manually via SSH. It could be something as simple as a stale host key.

### Configure cluster variables

Edit `inventory/$CLUSTER/group_vars/all/all.yml`:

- **bin_dir**:

```yml
# Directory where the binaries will be installed
# Default:
# bin_dir: /usr/local/bin
# For Flatcar Container Linux by Kinvolk:
bin_dir: /opt/bin
```

- and **cloud_provider**:

```yml
cloud_provider: openstack
```

Edit `inventory/$CLUSTER/group_vars/k8s-cluster/k8s-cluster.yml`:

- Set variable **kube_network_plugin** to your desired networking plugin.
  - **flannel** works out-of-the-box
  - **calico** requires [configuring OpenStack Neutron ports](/docs/openstack.md) to allow service and pod subnets

```yml
# Choose network plugin (calico, weave or flannel)
# Can also be set to 'cloud', which lets the cloud provider setup appropriate routing
kube_network_plugin: flannel
```

- Set variable **resolvconf_mode**

```yml
# Can be docker_dns, host_resolvconf or none
# Default:
# resolvconf_mode: docker_dns
# For Flatcar Container Linux by Kinvolk:
resolvconf_mode: host_resolvconf
```

- Set max amount of attached cinder volume per host (default 256)

```yml
node_volume_attach_limit: 26
```

### Deploy Kubernetes

```ShellSession
ansible-playbook --become -i inventory/$CLUSTER/hosts cluster.yml
```

This will take some time as there are many tasks to run.

## Kubernetes

### Set up kubectl

1. [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) on your workstation
2. Add a route to the internal IP of a master node (if needed):

```ShellSession
sudo route add [master-internal-ip] gw [router-ip]
```

or

```ShellSession
sudo route add -net [internal-subnet]/24 gw [router-ip]
```

1. List Kubernetes certificates & keys:

```ShellSession
ssh [os-user]@[master-ip] sudo ls /etc/kubernetes/ssl/
```

1. Get `admin`'s certificates and keys:

```ShellSession
ssh [os-user]@[master-ip] sudo cat /etc/kubernetes/ssl/admin-kube-master-1-key.pem > admin-key.pem
ssh [os-user]@[master-ip] sudo cat /etc/kubernetes/ssl/admin-kube-master-1.pem > admin.pem
ssh [os-user]@[master-ip] sudo cat /etc/kubernetes/ssl/ca.pem > ca.pem
```

1. Configure kubectl:

```ShellSession
$ kubectl config set-cluster default-cluster --server=https://[master-internal-ip]:6443 \
    --certificate-authority=ca.pem

$ kubectl config set-credentials default-admin \
    --certificate-authority=ca.pem \
    --client-key=admin-key.pem \
    --client-certificate=admin.pem

$ kubectl config set-context default-system --cluster=default-cluster --user=default-admin
$ kubectl config use-context default-system
```

1. Check it:

```ShellSession
kubectl version
```

## GlusterFS

GlusterFS is not deployed by the standard `cluster.yml` playbook, see the
[GlusterFS playbook documentation](../../network-storage/glusterfs/README.md)
for instructions.

Basically you will install Gluster as

```ShellSession
ansible-playbook --become -i inventory/$CLUSTER/hosts ./contrib/network-storage/glusterfs/glusterfs.yml
```

## What's next

Try out your new Kubernetes cluster with the [Hello Kubernetes service](https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/).

## Appendix

### Migration from `number_of_k8s_nodes*` to `k8s_nodes`

If you currently have a cluster defined using the `number_of_k8s_nodes*` variables and wish
to migrate to the `k8s_nodes` style you can do it like so:

```ShellSession
$ terraform state list
module.compute.data.openstack_images_image_v2.gfs_image
module.compute.data.openstack_images_image_v2.vm_image
module.compute.openstack_compute_floatingip_associate_v2.k8s_master[0]
module.compute.openstack_compute_floatingip_associate_v2.k8s_node[0]
module.compute.openstack_compute_floatingip_associate_v2.k8s_node[1]
module.compute.openstack_compute_floatingip_associate_v2.k8s_node[2]
module.compute.openstack_compute_instance_v2.k8s_master[0]
module.compute.openstack_compute_instance_v2.k8s_node[0]
module.compute.openstack_compute_instance_v2.k8s_node[1]
module.compute.openstack_compute_instance_v2.k8s_node[2]
module.compute.openstack_compute_keypair_v2.k8s
module.compute.openstack_compute_servergroup_v2.k8s_etcd[0]
module.compute.openstack_compute_servergroup_v2.k8s_master[0]
module.compute.openstack_compute_servergroup_v2.k8s_node[0]
module.compute.openstack_networking_secgroup_rule_v2.bastion[0]
module.compute.openstack_networking_secgroup_rule_v2.egress[0]
module.compute.openstack_networking_secgroup_rule_v2.k8s
module.compute.openstack_networking_secgroup_rule_v2.k8s_allowed_remote_ips[0]
module.compute.openstack_networking_secgroup_rule_v2.k8s_allowed_remote_ips[1]
module.compute.openstack_networking_secgroup_rule_v2.k8s_allowed_remote_ips[2]
module.compute.openstack_networking_secgroup_rule_v2.k8s_master[0]
module.compute.openstack_networking_secgroup_rule_v2.worker[0]
module.compute.openstack_networking_secgroup_rule_v2.worker[1]
module.compute.openstack_networking_secgroup_rule_v2.worker[2]
module.compute.openstack_networking_secgroup_rule_v2.worker[3]
module.compute.openstack_networking_secgroup_rule_v2.worker[4]
module.compute.openstack_networking_secgroup_v2.bastion[0]
module.compute.openstack_networking_secgroup_v2.k8s
module.compute.openstack_networking_secgroup_v2.k8s_master
module.compute.openstack_networking_secgroup_v2.worker
module.ips.null_resource.dummy_dependency
module.ips.openstack_networking_floatingip_v2.k8s_master[0]
module.ips.openstack_networking_floatingip_v2.k8s_node[0]
module.ips.openstack_networking_floatingip_v2.k8s_node[1]
module.ips.openstack_networking_floatingip_v2.k8s_node[2]
module.network.openstack_networking_network_v2.k8s[0]
module.network.openstack_networking_router_interface_v2.k8s[0]
module.network.openstack_networking_router_v2.k8s[0]
module.network.openstack_networking_subnet_v2.k8s[0]
$ terraform state mv 'module.compute.openstack_compute_floatingip_associate_v2.k8s_node[0]' 'module.compute.openstack_compute_floatingip_associate_v2.k8s_nodes["1"]'
Move "module.compute.openstack_compute_floatingip_associate_v2.k8s_node[0]" to "module.compute.openstack_compute_floatingip_associate_v2.k8s_nodes[\"1\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.compute.openstack_compute_floatingip_associate_v2.k8s_node[1]' 'module.compute.openstack_compute_floatingip_associate_v2.k8s_nodes["2"]'
Move "module.compute.openstack_compute_floatingip_associate_v2.k8s_node[1]" to "module.compute.openstack_compute_floatingip_associate_v2.k8s_nodes[\"2\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.compute.openstack_compute_floatingip_associate_v2.k8s_node[2]' 'module.compute.openstack_compute_floatingip_associate_v2.k8s_nodes["3"]'
Move "module.compute.openstack_compute_floatingip_associate_v2.k8s_node[2]" to "module.compute.openstack_compute_floatingip_associate_v2.k8s_nodes[\"3\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.compute.openstack_compute_instance_v2.k8s_node[0]' 'module.compute.openstack_compute_instance_v2.k8s_node["1"]'
Move "module.compute.openstack_compute_instance_v2.k8s_node[0]" to "module.compute.openstack_compute_instance_v2.k8s_node[\"1\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.compute.openstack_compute_instance_v2.k8s_node[1]' 'module.compute.openstack_compute_instance_v2.k8s_node["2"]'
Move "module.compute.openstack_compute_instance_v2.k8s_node[1]" to "module.compute.openstack_compute_instance_v2.k8s_node[\"2\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.compute.openstack_compute_instance_v2.k8s_node[2]' 'module.compute.openstack_compute_instance_v2.k8s_node["3"]'
Move "module.compute.openstack_compute_instance_v2.k8s_node[2]" to "module.compute.openstack_compute_instance_v2.k8s_node[\"3\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.ips.openstack_networking_floatingip_v2.k8s_node[0]' 'module.ips.openstack_networking_floatingip_v2.k8s_node["1"]'
Move "module.ips.openstack_networking_floatingip_v2.k8s_node[0]" to "module.ips.openstack_networking_floatingip_v2.k8s_node[\"1\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.ips.openstack_networking_floatingip_v2.k8s_node[1]' 'module.ips.openstack_networking_floatingip_v2.k8s_node["2"]'
Move "module.ips.openstack_networking_floatingip_v2.k8s_node[1]" to "module.ips.openstack_networking_floatingip_v2.k8s_node[\"2\"]"
Successfully moved 1 object(s).
$ terraform state mv 'module.ips.openstack_networking_floatingip_v2.k8s_node[2]' 'module.ips.openstack_networking_floatingip_v2.k8s_node["3"]'
Move "module.ips.openstack_networking_floatingip_v2.k8s_node[2]" to "module.ips.openstack_networking_floatingip_v2.k8s_node[\"3\"]"
Successfully moved 1 object(s).
```

Of course for nodes without floating ips those steps can be omitted.
