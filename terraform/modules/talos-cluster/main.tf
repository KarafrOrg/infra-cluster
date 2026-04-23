data "proxmox_virtual_environment_nodes" "available" {}

module "virtual_machines_control_plane" {
  for_each = local.control_plane_vms
  source   = "../proxmox-virtual-machine"

  vm_name        = each.value["name"]
  node_name      = each.value["node_name"]
  network_bridge = var.network_bridge
  vm_image_link  = var.talos_image_url
  vm_image_name  = var.talos_image_name
  vm_memory      = var.control_plane.spec.memory
  vm_disk_size   = var.control_plane.spec.disk_size
  cpu_cores      = var.control_plane.spec.cpu_cores

  vm_tags = ["talos", "control-plane"]
}

module "internal_network" {
  source     = "../proxmox-sdlan"
  dns_server = var.networking.dns_server
  dns_zone   = var.networking.dns_zone
  name       = "kubesdn"
}
