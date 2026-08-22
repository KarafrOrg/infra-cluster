variable "metrics_server" {
  description = "Metrics Server Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "metrics-server")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://kubernetes-sigs.github.io/metrics-server/")
  })
  default = {}
}

variable "node_exporter" {
  description = "Node Exporter Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "node-exporter")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://prometheus-community.github.io/helm-charts")
  })
  default = {}
}

variable "prometheus_operator" {
  description = "Prometheus Operator Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "prometheus-operator")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://prometheus-community.github.io/helm-charts")
  })
  default = {}
}
