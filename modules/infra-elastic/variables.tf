variable "eck_operator" {
  description = "Elastic Cloud on Kubernetes (ECK) operator Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "eck-operator")
    release_namespace  = optional(string, "infra-elastic")
    release_repository = optional(string, "https://helm.elastic.co")
  })
  default = {}
}
