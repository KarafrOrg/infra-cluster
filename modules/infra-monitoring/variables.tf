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
    root_url           = optional(string, "https://grafana.kubernetes.karafra.net")
    github_oauth = optional(object({
      enabled                     = optional(bool, true)
      org                         = optional(string, "KarafrOrg")
      admin_team                  = optional(string, "grafana-admins")
      viewer_team                 = optional(string, "grafana-viewers")
      client_id_gcp_secret_id     = optional(string, "grafana-github-oauth-client-id")
      client_secret_gcp_secret_id = optional(string, "grafana-github-oauth-client-secret")
      secret_store_name           = optional(string, "gcp-cluster-secret-store")
    }), {})
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

variable "pyroscope" {
  description = "Grafana Pyroscope Helm release configuration (also toggles the eBPF profiling Alloy DaemonSet)."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "pyroscope")
    release_namespace  = optional(string, "infra-monitoring")
    release_repository = optional(string, "https://grafana.github.io/helm-charts")
  })
  default = {}
}

variable "gateway_class_name" {
  description = "GatewayClass used by the dedicated Gateways of published services."
  type        = string
  default     = "cloudflare-tunnel"
}

variable "gateway_tunnel_replicas" {
  description = "Tunnel replicas for each dedicated Gateway."
  type        = list(object({ name = string, zone = string }))
}

variable "gateway_cloudflare_account_id_secret" {
  description = "GCP Secret Manager secret ID holding the Cloudflare account ID for the dedicated Gateways."
  type        = string
}

variable "gateway_cloudflare_api_token_secret" {
  description = "GCP Secret Manager secret ID holding the Cloudflare API token for the dedicated Gateways."
  type        = string
}
