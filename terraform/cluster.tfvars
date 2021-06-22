# your Kubernetes cluster name here
cluster_name = "hl"

# list of availability zones available in your OpenStack cluster
az_list = ["kvm-hdd"]
az_list_node = ["kvm-hdd"]

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"

# image to use for bastion, masters, standalone etcd instances, and nodes
image = "kvm-ubuntu-focal"

# user on the node (ex. core on Container Linux, ubuntu on Ubuntu, etc.)
ssh_user = "ubuntu"

# masters
number_of_k8s_masters_no_floating_ip= 1
flavor_k8s_master_name = "m1.medium"

# nodes
number_of_k8s_nodes_no_floating_ip = 2
flavor_k8s_node_name = "m1.medium"


# networking
network_name = "cluster-net"
subnet_cidr = "172.24.32.0/19"
k8s_allowed_remote_ips = ["0.0.0.0/0"]