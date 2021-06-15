data "openstack_images_image_v2" "vm_image" {
  name = var.image
}

resource "openstack_compute_keypair_v2" "k8s" {
  name       = "kubernetes-${var.cluster_name}"
  public_key = chomp(file(var.public_key_path))
}

resource "openstack_networking_secgroup_v2" "k8s_master" {
  name                 = "${var.cluster_name}-k8s-master"
  description          = "${var.cluster_name} - Kubernetes Master"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "k8s_master" {
  count             = length(var.master_allowed_remote_ips)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "6443"
  port_range_max    = "6443"
  remote_ip_prefix  = var.master_allowed_remote_ips[count.index]
  security_group_id = openstack_networking_secgroup_v2.k8s_master.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_master_ports" {
  count             = length(var.master_allowed_ports)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = lookup(var.master_allowed_ports[count.index], "protocol", "tcp")
  port_range_min    = lookup(var.master_allowed_ports[count.index], "port_range_min")
  port_range_max    = lookup(var.master_allowed_ports[count.index], "port_range_max")
  remote_ip_prefix  = lookup(var.master_allowed_ports[count.index], "remote_ip_prefix", "0.0.0.0/0")
  security_group_id = openstack_networking_secgroup_v2.k8s_master.id
}

resource "openstack_networking_secgroup_v2" "k8s" {
  name                 = "${var.cluster_name}-k8s"
  description          = "${var.cluster_name} - Kubernetes"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "k8s" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = openstack_networking_secgroup_v2.k8s.id
  security_group_id = openstack_networking_secgroup_v2.k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_allowed_remote_ips" {
  count             = length(var.k8s_allowed_remote_ips)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "22"
  port_range_max    = "22"
  remote_ip_prefix  = var.k8s_allowed_remote_ips[count.index]
  security_group_id = openstack_networking_secgroup_v2.k8s.id
}

resource "openstack_networking_secgroup_rule_v2" "egress" {
  count             = length(var.k8s_allowed_egress_ips)
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.k8s_allowed_egress_ips[count.index]
  security_group_id = openstack_networking_secgroup_v2.k8s.id
}

resource "openstack_networking_secgroup_v2" "worker" {
  name                 = "${var.cluster_name}-k8s-worker"
  description          = "${var.cluster_name} - Kubernetes worker nodes"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "worker" {
  count             = length(var.worker_allowed_ports)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = lookup(var.worker_allowed_ports[count.index], "protocol", "tcp")
  port_range_min    = lookup(var.worker_allowed_ports[count.index], "port_range_min")
  port_range_max    = lookup(var.worker_allowed_ports[count.index], "port_range_max")
  remote_ip_prefix  = lookup(var.worker_allowed_ports[count.index], "remote_ip_prefix", "0.0.0.0/0")
  security_group_id = openstack_networking_secgroup_v2.worker.id
}

locals {
  # master groups
  master_sec_groups = compact([
    openstack_networking_secgroup_v2.k8s_master.name,
    openstack_networking_secgroup_v2.k8s.name,
    var.extra_sec_groups ? openstack_networking_secgroup_v2.k8s_master_extra[0].name : "",
  ])
  # worker groups
  worker_sec_groups = compact([
    openstack_networking_secgroup_v2.k8s.name,
    openstack_networking_secgroup_v2.worker.name,
    var.extra_sec_groups ? openstack_networking_secgroup_v2.k8s_master_extra[0].name : "",
  ])
}

resource "openstack_compute_instance_v2" "k8s_master_no_floating_ip" {
  name              = "${var.cluster_name}-k8s-master-${count.index + 1}"
  count             = var.number_of_k8s_masters_no_floating_ip
  availability_zone = element(var.az_list, count.index)
  image_name        = var.image
  flavor_name       = var.flavor_k8s_master_name
  flavor_id         = var.flavor_k8s_master
  key_pair          = openstack_compute_keypair_v2.k8s.name

  dynamic "block_device" {
    for_each = var.master_root_volume_size_in_gb > 0 ? [var.image] : []
    content {
      uuid                  = data.openstack_images_image_v2.vm_image.id
      source_type           = "image"
      volume_size           = var.master_root_volume_size_in_gb
      volume_type           = var.master_volume_type
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = true
    }
  }

  network {
    name = var.network_name
  }

  security_groups = local.master_sec_groups

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [openstack_compute_servergroup_v2.k8s_master[0]] : []
    content {
      group = openstack_compute_servergroup_v2.k8s_master[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "etcd,kube-master,${var.supplementary_master_groups},k8s-cluster,vault,no-floating"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }
}

resource "openstack_compute_instance_v2" "k8s_node_no_floating_ip" {
  name              = "${var.cluster_name}-k8s-node-${count.index + 1}"
  count             = var.number_of_k8s_nodes_no_floating_ip
  availability_zone = element(var.az_list_node, count.index)
  image_name        = var.image
  flavor_name       = var.flavor_k8s_node_name
  flavor_id         = var.flavor_k8s_node
  key_pair          = openstack_compute_keypair_v2.k8s.name

  dynamic "block_device" {
    for_each = var.node_root_volume_size_in_gb > 0 ? [var.image] : []
    content {
      uuid                  = data.openstack_images_image_v2.vm_image.id
      source_type           = "image"
      volume_size           = var.node_root_volume_size_in_gb
      boot_index            = 0
      destination_type      = "volume"
      delete_on_termination = true
    }
  }

  network {
    name = var.network_name
  }

  security_groups = local.worker_sec_groups

  dynamic "scheduler_hints" {
    for_each = var.use_server_groups ? [openstack_compute_servergroup_v2.k8s_node[0]] : []
    content {
      group = openstack_compute_servergroup_v2.k8s_node[0].id
    }
  }

  metadata = {
    ssh_user         = var.ssh_user
    kubespray_groups = "kube-node,k8s-cluster,no-floating,${var.supplementary_node_groups}"
    depends_on       = var.network_id
    use_access_ip    = var.use_access_ip
  }
}

