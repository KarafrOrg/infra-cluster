variable "control_plane" {
  description = "Configuration for the control plane node"
  type = object({
    node_count     = number
    vm_name_prefix = string
    spec = object({
      memory = object({
        dedicated = number
        floating  = number
      })
      disk_size = number
      cpu_cores = number
    })
  })
}

variable "networking" {
  description = "Networking configuration for the cluster"
  type = object({
    dns_server = string
    dns_zone   = string
  })
  default = {
    dns_server = "1.1.1.1"
    dns_zone   = "k8s.lan"
  }
}

variable "network_bridge" {
  description = "Bridge / SDN VNet to attach VMs to"
  type        = string
  default     = "vmbr1"
}

variable "talos_image_url" {
  description = "URL to the Talos ISO image to use for the VMs"
  type        = string
}

variable "talos_image_name" {
  description = "File name of the Talos ISO image to use for the VMs"
  type        = string
}

variable "proxmox_api_url" {
  description = "URL of the Proxmox API endpoint, e.g. https://proxmox.example.com:8006/api2/json"
  type        = string
}

variable "proxmox_user" {
  description = "Username for Proxmox API authentication, e.g. root@pam"
  type        = string
}

variable "proxmox_password" {
  description = "Password for Proxmox API authentication"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Whether to skip TLS verification when connecting to Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node_ips" {
  description = "Physical IP addresses of all Proxmox nodes — used as VXLAN underlay peers"
  type        = list(string)
}
