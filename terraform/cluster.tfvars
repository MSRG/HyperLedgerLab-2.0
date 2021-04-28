# your Kubernetes cluster name here
cluster_name = "hyperledgerLab"

# list of availability zones available in your OpenStack cluster
az_list = ["kvm-hdd"]
az_list_node = ["kvm-hdd"]
# SSH key to use for access to nodes
public_key_path = "~/.ssh/id_rsa.pub"

# image to use for bastion, masters, standalone etcd instances, and nodes
image = "kvm-ubuntu-focal"

# user on the node (ex. core on Container Linux, ubuntu on Ubuntu, etc.)
ssh_user = "ubuntu"

# 0|1 bastion nodes
number_of_bastions = 0

# standalone etcds
number_of_etcd = 0

# masters
number_of_k8s_masters = 0

number_of_k8s_masters_no_etcd = 0

number_of_k8s_masters_no_floating_ip = 1

number_of_k8s_masters_no_floating_ip_no_etcd = 0

flavor_k8s_master = "3a079e8e-db5f-4782-97a1-13997d98d57f" //m1.medium 

# nodes
number_of_k8s_nodes = 0

number_of_k8s_nodes_no_floating_ip = 2

flavor_k8s_node = "3a079e8e-db5f-4782-97a1-13997d98d57f" //m1.medium 

# networking
network_name = "cluster-net"
subnet_cidr = "172.24.32.0/19"
external_net = ""
k8s_allowed_remote_ips = ["0.0.0.0/0"]