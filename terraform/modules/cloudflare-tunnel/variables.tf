variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "tunnel_name" {
  type    = string
  default = "karafra-net"
}

# List of VMs to expose via the tunnel
# Each entry: { subdomain, ip, port, protocol }
variable "tunnel_ingress" {
  type = list(object({
    subdomain     = string
    ip            = string
    port          = number
    protocol      = optional(string, "http")
    no_tls_verify = optional(bool, false)
  }))
  default = []
}

variable "private_network_cidr" {
  type        = string
  default     = "10.10.10.0/24"
  description = "Private network CIDR routed through the tunnel (Talos VMs)"
}

variable "domain" {
  type = string
}

