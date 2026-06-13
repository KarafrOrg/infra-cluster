variable "external_secrets_helm_release_name" {
  description = "The name of the Helm release for External Secrets."
  type        = string
}

variable "external_secrets_helm_release_repository" {
  description = "The Helm repository URL for External Secrets."
  type        = string
}

variable "external_secrets_helm_release_namespace" {
  description = "The Kubernetes namespace where External Secrets will be deployed."
  type        = string
}

variable "external_secrets_gcp_sa_account_id" {
  description = "The account ID of the Google Cloud service account to be used by External Secrets."
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID where Secret Manager secrets are stored."
  type        = string
}

