variable "network_bridge" {
  description = "Bridge to attach VMs to (e.g. the SDN VNet name)"
  type        = string
  default     = "vmbr1"
}

variable "vm_image_name" {
  description = "Name of the image to use for the VM (e.g. talos-1.12.6-amd64.iso)"
  type        = string
}

variable "vm_image_link" {
  description = "URL to the image to use for the VM (e.g.https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.12.6/nocloud-amd64.iso"
  type        = string
}

variable "node_name" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM to create"
  type        = string
}

variable "vm_memory" {
  description = "Memory size for the VM in MiB"
  type = object({
    dedicated = number
    floating  = number
  })
}

variable "vm_disk_size" {
  description = "Disk size for the VM in GiB"
  type        = number
  validation {
    condition     = var.vm_disk_size >= 20
    error_message = "vm_disk_size cannot be less than 20"
  }
}

variable "vm_tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = []
}

variable "cpu_cores" {
  description = "Number of CPU cores to allocate to the VM"
  type        = number
  default     = 2
  validation {
    condition     = var.cpu_cores >= 2
    error_message = "cpu_cores must be at least 2"
  }
}
