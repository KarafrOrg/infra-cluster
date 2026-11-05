variable "k8s_cluster_token" {
  description = "The authentication token for the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_client_certificate" {
  description = "The client certificate for the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_certificate_authority" {
  description = "The certificate authority for the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_host" {
  description = "The host URL of the Kubernetes cluster."
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token used to provision tunnels and DNS via the Cloudflare Terraform provider."
  type        = string
  sensitive   = true
}

variable "argocd" {
  description = "Whether to deploy Argo CD in the cluster."
  type = object({
    enabled                                  = optional(bool, true),
    release_name                             = optional(string, "argocd"),
    release_namespace                        = optional(string, "infra-cicd"),
    release_repository                       = optional(string, "https://argoproj.github.io/argo-helm"),
    ingress_domain                           = string,
    github_org                               = string,
    github_app_id_gcp_secret_id              = string,
    github_app_installation_id_gcp_secret_id = string,
    github_app_private_key_gcp_secret_id     = string,
    github_sso_client_id_gcp_secret_id       = string,
    github_sso_client_secret_gcp_secret_id   = string,
    github_sso_admin_team                    = optional(string, "argocd-admins"),
  })
}

variable "cert_manager" {
  description = "cert-manager configuration for automated TLS certificate management via Let's Encrypt DNS-01."
  type = object({
    enabled                            = optional(bool, true)
    release_name                       = optional(string, "cert-manager")
    release_namespace                  = optional(string, "infra-certs")
    release_version                    = optional(string, "v1.17.2")
    cluster_issuer_name                = optional(string, "letsencrypt-prod")
    acme_email                         = string
    cloudflare_api_token_gcp_secret_id = string
  })
}

variable "external_secrets" {
  description = "Whether to deploy External Secrets in the cluster."
  type = object({
    enabled            = optional(bool, true),
    release_name       = optional(string, "external-secrets"),
    release_namespace  = optional(string, "infra-secrets"),
    release_repository = optional(string, "https://charts.external-secrets.io"),
    gcp_sa_account_id  = string,
    gcp_project_id     = string,
  })
}

variable "metallb" {
  description = "MetalLB Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "metallb")
    release_namespace  = optional(string, "infra-network")
    release_repository = optional(string, "https://metallb.github.io/metallb")
    internal_cidr      = optional(string, "10.44.0.0/24")
  })
  default = {}
}

variable "external_dns" {
  description = "ExternalDNS Helm release configuration with Cloudflare backend."
  type = object({
    enabled                     = optional(bool, true)
    release_name                = optional(string, "external-dns")
    release_namespace           = optional(string, "infra-network")
    release_repository          = optional(string, "https://kubernetes-sigs.github.io/external-dns/")
    domain_filter               = string
    txt_owner_id                = optional(string, "external-dns")
    cloudflare_api_token_secret = string
  })
}

variable "cloudflare_gateway_controller" {
  description = "Cloudflare Gateway Controller (matheuscscp/cloudflare-gateway-controller) configuration, running highly available tunnel replicas spread across zones and nodes."
  type = object({
    enabled                      = optional(bool, true)
    release_name                 = optional(string, "cloudflare-gateway-controller")
    release_namespace            = optional(string, "infra-network")
    chart_version                = optional(string, "0.16.0")
    cluster_name                 = string
    controller_replicas          = optional(number, 1)
    gateway_class_name           = optional(string, "cloudflare-tunnel")
    gateway_name                 = optional(string, "cloudflare-tunnel")
    tunnel_replicas              = list(object({ name = string, zone = string }))
    cloudflare_account_id_secret = string
    cloudflare_api_token_secret  = string
  })

  validation {
    condition     = length(distinct([for r in var.cloudflare_gateway_controller.tunnel_replicas : r.zone])) >= 3
    error_message = "tunnel_replicas must span at least 3 distinct zones for a highly available tunnel."
  }
}

variable "istio" {
  description = "Istio service mesh configuration (ambient mode) with CNI, ztunnel, and ingress gateway."
  type = object({
    enabled           = optional(bool, true)
    release_namespace = optional(string, "infra-network")
    version           = optional(string, "1.28.2")
    cni_platform      = optional(string)
    tracing_service   = optional(string, "infra-monitoring-tempo.infra-monitoring.svc.cluster.local")
    tracing_port      = optional(number, 4317)
    ingress_domain    = string
    cert_issuer_name  = optional(string, "letsencrypt-dns")
  })
}

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
    carto = optional(object({
      enabled               = optional(bool, true)
      api_key_gcp_secret_id = optional(string, "grafana-carto-api-key")
      secret_store_name     = optional(string, "gcp-cluster-secret-store")
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
