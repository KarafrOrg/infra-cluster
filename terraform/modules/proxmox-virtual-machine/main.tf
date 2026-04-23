data "proxmox_virtual_environment_nodes" "nodes" {}

resource "proxmox_download_file" "cloud_image" {
  datastore_id = "local"
  content_type = "iso"
  node_name    = var.node_name
  url          = var.vm_image_link
  file_name    = var.vm_image_name
}

resource "proxmox_virtual_environment_vm" "talos_vm" {
  name = var.vm_name
  tags = concat(local.default_tags, var.vm_tags)

  node_name = var.node_name

  agent {
    enabled = false
  }

  stop_on_destroy = true

  boot_order = ["ide2", "scsi0"]

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.vm_memory.dedicated
    floating  = var.vm_memory.floating
  }

  cdrom {
    file_id   = proxmox_download_file.cloud_image.id
    interface = "ide2"
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    size         = var.vm_disk_size
    file_format  = "raw"
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  tpm_state {
    datastore_id = "local"
    version      = "v2.0"
  }

  serial_device {}
}
