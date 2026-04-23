output "vm_id" {
  description = "The Proxmox VM ID"
  value       = proxmox_virtual_environment_vm.talos_vm.id
}

output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.talos_vm.name
}

output "vm_node" {
  description = "The Proxmox node the VM is running on"
  value       = proxmox_virtual_environment_vm.talos_vm.node_name
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses of the VM (requires QEMU guest agent)"
  value       = proxmox_virtual_environment_vm.talos_vm.ipv4_addresses
}

output "vm_mac_addresses" {
  description = "MAC addresses of the VM network interfaces"
  value       = proxmox_virtual_environment_vm.talos_vm.mac_addresses
}

output "cloud_image_id" {
  description = "ID of the downloaded cloud image file"
  value       = proxmox_download_file.cloud_image.id
}

