variable "dns_server" {
  description = "The IP address of the Proxmox SDLAN DNS server."
  type        = string
}


variable "name" {
  description = "Name of the SDLAN network to create in Proxmox."
  type        = string
}

variable "dns_zone" {
  description = "DNS zone to use for reverse DNS entries for the SDLAN network."
  type        = string
}
