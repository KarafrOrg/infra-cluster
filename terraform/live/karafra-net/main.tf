module "talos_cluster" {
  source           = "../../modules/talos-cluster"
  control_plane    = var.control_plane
  talos_image_name = var.talos_image_name
  talos_image_url  = var.talos_image_url
  proxmox_api_url  = var.proxmox_api_url
  proxmox_password = var.proxmox_password
  proxmox_user     = var.proxmox_user
  proxmox_node_ips = var.proxmox_node_ips
}
