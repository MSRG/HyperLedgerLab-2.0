variable "cluster_name" {}

variable "az_list" {
  type = list(string)
}

variable "az_list_node" {
  type = list(string)
}

variable "number_of_k8s_masters_no_floating_ip" {}

variable "number_of_k8s_nodes" {}

variable "number_of_k8s_nodes_no_floating_ip" {}

variable "master_root_volume_size_in_gb" {}

variable "node_root_volume_size_in_gb" {}

variable "master_volume_type" {}

variable "public_key_path" {}

variable "image" {}

variable "ssh_user" {}

variable "flavor_k8s_master" {}

variable "flavor_k8s_node" {}

variable "flavor_k8s_master_name" {}

variable "flavor_k8s_node_name" {}

variable "network_name" {}

variable "network_id" {
  default = ""
}

variable "k8s_nodes_fips" {
  type = map(any)
}

variable "bastion_fips" {
  type = list(any)
}

variable "master_allowed_remote_ips" {
  type = list(any)
}

variable "k8s_allowed_remote_ips" {
  type = list(any)
}

variable "k8s_allowed_egress_ips" {
  type = list(any)
}

variable "k8s_nodes" {}

variable "supplementary_master_groups" {
  default = ""
}

variable "supplementary_node_groups" {
  default = ""
}

variable "master_allowed_ports" {
  type = list(any)
}

variable "worker_allowed_ports" {
  type = list(any)
}

variable "use_access_ip" {}

variable "use_server_groups" {
  type = bool
}

variable "extra_sec_groups" {
  type = bool
}
