variable "argo_cd_helm_release_name" {
  description = "The name of the Argo CD Helm release."
  type        = string
}

variable "argo_cd_helm_release_repository" {
  description = "The repository URL for the Argo CD Helm chart."
  type        = string
}

variable "argo_cd_helm_release_namespace" {
  description = "The namespace in which to install the Argo CD Helm release."
  type        = string
}

variable "argocd_ingress_domain" {
  description = "The domain name for the Argo CD ingress."
  type        = string
}

variable "cluster_issuer_name" {
  description = "Name of the cert-manager ClusterIssuer to use for the ArgoCD origin TLS certificate."
  type        = string
  default     = "letsencrypt-prod"
}
