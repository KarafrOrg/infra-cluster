variable "release_name" {
  description = "Helm release name for cert-manager."
  type        = string
  default     = "cert-manager"
}

variable "release_namespace" {
  description = "Namespace to install cert-manager into."
  type        = string
  default     = "infra-network"
}

variable "release_version" {
  description = "cert-manager Helm chart version."
  type        = string
  default     = "v1.17.2"
}

variable "acme_email" {
  description = "Email address for Let's Encrypt ACME account registration."
  type        = string
}

variable "cloudflare_api_token_gcp_secret_id" {
  description = "GCP Secret Manager secret ID that holds the Cloudflare API token used for DNS-01 challenges."
  type        = string
}

variable "cluster_issuer_name" {
  description = "Name of the ClusterIssuer resource to create."
  type        = string
  default     = "letsencrypt-prod"
}
