module "ips" {
  source = "./modules/ips"

  number_of_k8s_masters         = var.number_of_k8s_masters
  number_of_k8s_masters_no_etcd = var.number_of_k8s_masters_no_etcd
  number_of_k8s_nodes           = var.number_of_k8s_nodes
  floatingip_pool               = var.floatingip_pool
  number_of_bastions            = var.number_of_bastions
  external_net                  = var.external_net
  network_name                  = var.network_name
  k8s_nodes                     = var.k8s_nodes
  k8s_master_fips               = var.k8s_master_fips
  router_internal_port_id       = ""
}

module "compute" {
  source = "./modules/compute"

  network_id                           = var.network_id
  cluster_name                         = var.cluster_name
  az_list                              = var.az_list
  az_list_node                         = var.az_list_node
  number_of_k8s_masters_no_floating_ip = var.number_of_k8s_masters_no_floating_ip
  number_of_k8s_nodes                  = var.number_of_k8s_nodes
  number_of_k8s_nodes_no_floating_ip   = var.number_of_k8s_nodes_no_floating_ip
  k8s_nodes                            = var.k8s_nodes
  master_root_volume_size_in_gb        = var.master_root_volume_size_in_gb
  node_root_volume_size_in_gb          = var.node_root_volume_size_in_gb
  master_volume_type                   = var.master_volume_type
  public_key_path                      = var.public_key_path
  image                                = var.image
  ssh_user                             = var.ssh_user
  flavor_k8s_master                    = var.flavor_k8s_master
  flavor_k8s_node                      = var.flavor_k8s_node
  network_name                         = var.network_name
  k8s_nodes_fips                       = module.ips.k8s_nodes_fips
  bastion_fips                         = module.ips.bastion_fips
  master_allowed_remote_ips            = var.master_allowed_remote_ips
  k8s_allowed_remote_ips               = var.k8s_allowed_remote_ips
  k8s_allowed_egress_ips               = var.k8s_allowed_egress_ips
  supplementary_master_groups          = var.supplementary_master_groups
  supplementary_node_groups            = var.supplementary_node_groups
  master_allowed_ports                 = var.master_allowed_ports
  worker_allowed_ports                 = var.worker_allowed_ports
  use_access_ip                        = var.use_access_ip
  use_server_groups                    = var.use_server_groups
  extra_sec_groups                     = var.extra_sec_groups
  flavor_k8s_node_name                 = var.flavor_k8s_node_name
  flavor_k8s_master_name               = var.flavor_k8s_master_name
}
