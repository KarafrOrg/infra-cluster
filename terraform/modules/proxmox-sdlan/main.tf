data "proxmox_virtual_environment_nodes" "available" {}

data "proxmox_virtual_environment_dns" "nodes" {
  for_each  = { for node in data.proxmox_virtual_environment_nodes.available.names : node => node }
  node_name = each.key
}

data "proxmox_virtual_environment_hosts" "nodes" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.available.names)
  node_name = each.key
}

resource "proxmox_virtual_environment_dns" "node_dns" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.available.names)
  domain    = data.proxmox_virtual_environment_dns.nodes[each.key].domain
  node_name = each.key

  servers = [var.dns_server]
}


resource "proxmox_sdn_zone_vxlan" "vxlan_zone" {
  id    = var.name
  nodes = data.proxmox_virtual_environment_nodes.available.names
  peers = local.node_ips
}
