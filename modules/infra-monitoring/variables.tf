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
    release_name       = optional(string, "prometheus-node-exporter")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://prometheus-community.github.io/helm-charts")
  })
  default = {}
}

variable "prometheus_operator_crds" {
  description = "Prometheus Operator CRDs Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "prometheus-operator-crds")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://prometheus-community.github.io/helm-charts")
  })
  default = {}
}

variable "kube_state_metrics" {
  description = "Kube State Metrics Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "kube-state-metrics")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://prometheus-community.github.io/helm-charts")
  })
  default = {}
}

variable "eck_monitoring" {
  description = "Elastic Cloud on Kubernetes (ECK) Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "eck-monitoring-stack")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://helm.elastic.co")
  })
  default = {}
}


variable "alloy" {
  description = "Alloy Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "alloy")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://grafana.github.io/helm-charts")
  })
  default = {}
}


variable "mimir" {
  description = "Grafana Mimir Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "mimir")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://grafana.github.io/helm-charts")
  })
  default = {}
}

variable "grafana" {
  description = "Grafana Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "grafana")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://grafana.github.io/helm-charts")
  })
  default = {}
}

variable "loki" {
  description = "Grafana Loki Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "loki")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://grafana.github.io/helm-charts")
  })
  default = {}
}

variable "tempo" {
  description = "Grafana Tempo Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "tempo")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://grafana.github.io/helm-charts")
  })
  default = {}
}

variable "gateway_name" {
  description = "Name of the shared Gateway the Kibana/Grafana HTTPRoutes attaches to."
  type        = string
  default     = "cloudflare-tunnel"
}

variable "gateway_namespace" {
  description = "Namespace of the shared Gateway the Kibana/Grafana HTTPRoutes attaches to."
  type        = string
  default     = "infra-network"
}
