locals {
  proxmox_nodes = data.proxmox_virtual_environment_nodes.available.names
  control_plane_vms = {
    for i in range(var.control_plane.node_count) :
    format("${var.control_plane.vm_name_prefix}%02d", i) => {
      name      = format("${var.control_plane.vm_name_prefix}%02d", i)
      node_name = local.proxmox_nodes[i % length(local.proxmox_nodes)]
    }
  }
}
