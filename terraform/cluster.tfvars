# your Kubernetes cluster name here
cluster_name = "hl"

# availability zone in the OpenStack cluster
availability_zone = "kvm-hdd"

# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"

# image to use for all instances
image = "kvm-ubuntu-focal"

# masters
number_of_k8s_masters_no_floating_ip = 1
flavor_k8s_master_name               = "m1.large"

# nodes
number_of_k8s_nodes_no_floating_ip = 2
flavor_k8s_node_name               = "m1.large"

# networking
network_name           = "cluster-net"
subnet_cidr            = "172.24.32.0/19"
k8s_allowed_remote_ips = ["0.0.0.0/0"]
