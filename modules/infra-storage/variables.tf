variable "longhorn" {
  description = "Longhorn Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "longhorn")
    release_namespace  = optional(string, "infra-storage")
    release_repository = optional(string, "https://charts.longhorn.io")
  })
  default = {}
}
