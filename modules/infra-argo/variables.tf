variable "argo_cd_helm_release_name" {
  description = "The name of the Argo CD Helm release."
  type        = string
}

variable "argo_cd_helm_release_repository" {
  description = "The repository URL for the Argo CD Helm chart."
  type        = string
}

variable "argo_cd_helm_release_version" {
  description = "The version of the Argo CD Helm chart."
  type        = string
  default     = "10.11.7"
}

variable "argo_cd_helm_release_namespace" {
  description = "The namespace in which to install the Argo CD Helm release."
  type        = string
}

variable "argocd_ingress_domain" {
  description = "The domain name for the Argo CD ingress."
  type        = string
}

variable "argocd_github_org" {
  description = "GitHub organization to use for Argo CD repositories and projects."
  type        = string
}

variable "cluster_issuer_name" {
  description = "Name of the cert-manager ClusterIssuer to use for the ArgoCD origin TLS certificate."
  type        = string
  default     = "letsencrypt-prod"
}

variable "argocd_github_app_id_gcp_secret_id" {
  description = "GCP Secret Manager secret ID holding the GitHub App ID for ArgoCD repository credentials."
  type        = string
}

variable "argocd_github_app_installation_id_gcp_secret_id" {
  description = "GCP Secret Manager secret ID holding the GitHub App Installation ID for ArgoCD repository credentials."
  type        = string
}

variable "argocd_github_app_private_key_gcp_secret_id" {
  description = "GCP Secret Manager secret ID holding the GitHub App private key for ArgoCD repository credentials."
  type        = string
}

variable "argocd_github_sso_client_id_gcp_secret_id" {
  description = "GCP Secret Manager secret ID holding the GitHub OAuth App client ID for ArgoCD SSO."
  type        = string
}

variable "argocd_github_sso_client_secret_gcp_secret_id" {
  description = "GCP Secret Manager secret ID holding the GitHub OAuth App client secret for ArgoCD SSO."
  type        = string
}

variable "argocd_github_sso_admin_team" {
  description = "GitHub team within the org that is granted the ArgoCD admin role."
  type        = string
  default     = "admin"
}


variable "edge_certificate_hosts" {
  description = "Hostnames on the cert-manager certificate. Wildcards cover a single subdomain level only."
  type        = list(string)
  default     = ["*.kubernetes.karafra.net"]
}

variable "gateway_class_name" {
  description = "GatewayClass used by the dedicated Argo CD Gateway."
  type        = string
  default     = "cloudflare-tunnel"
}

variable "gateway_tunnel_replicas" {
  description = "Tunnel replicas for the Argo CD Gateway."
  type        = list(object({ name = string, zone = string }))
}

variable "gateway_cloudflare_account_id_secret" {
  description = "GCP Secret Manager secret ID holding the Cloudflare account ID for the Argo CD Gateway."
  type        = string
}

variable "gateway_cloudflare_api_token_secret" {
  description = "GCP Secret Manager secret ID holding the Cloudflare API token for the Argo CD Gateway."
  type        = string
}

variable "faro_host" {
  description = "In-cluster DNS name of the Faro receiver (Alloy) the Argo CD frontend proxy forwards browser telemetry to."
  type        = string
}

variable "private_gateway" {
  description = "Private (WARP-only) gateway the service is published through."
  type = object({
    name      = string
    namespace = string
    target_ip = string
  })
}
