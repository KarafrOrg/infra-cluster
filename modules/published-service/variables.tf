variable "name" {
  description = "Name of the published service; used for the Gateway, HTTPRoute and `<name>-frontend-proxy`."
  type        = string
}

variable "namespace" {
  description = "Namespace of the service (the Gateway, proxy and route are created here)."
  type        = string
}

variable "hostnames" {
  description = "Public hostnames routed to the service."
  type        = list(string)
}

variable "upstream_host" {
  description = "In-cluster DNS name of the service the proxy forwards to."
  type        = string
}

variable "upstream_port" {
  description = "Port of the upstream service."
  type        = number
  default     = 80
}

variable "app_name" {
  description = "Faro app name; defaults to `name`."
  type        = string
  default     = null
}

variable "environment" {
  description = "Faro environment label."
  type        = string
  default     = "production"
}

variable "faro_host" {
  description = "In-cluster DNS name of the Faro receiver (Alloy)."
  type        = string
}

variable "faro_port" {
  description = "Port of the Faro receiver."
  type        = number
  default     = 12347
}

variable "faro_path" {
  description = "Same-origin path the browser posts Faro telemetry to."
  type        = string
  default     = "/faro/collect"
}

variable "faro_version" {
  description = "Faro Web SDK version injected into HTML responses."
  type        = string
  default     = "2.13.0"
}

variable "envoy_version" {
  description = "Envoy image tag."
  type        = string
  default     = "v1.36.2"
}

variable "create_gateway" {
  description = "Create a dedicated Gateway (with tunnel parameters and credentials) for the service. When false, `gateway_name` must already exist in `namespace`."
  type        = bool
  default     = true
}

variable "gateway_name" {
  description = "Existing Gateway to attach to when `create_gateway` is false; defaults to `name`."
  type        = string
  default     = null
}

variable "gateway_class_name" {
  description = "GatewayClass of the dedicated Gateway."
  type        = string
  default     = "cloudflare-tunnel"
}

variable "tunnel_replicas" {
  description = "Tunnel replicas of the dedicated Gateway."
  type        = list(object({ name = string, zone = string }))
  default     = []
}

variable "cloudflare_account_id_secret" {
  description = "GCP Secret Manager secret ID with the Cloudflare account ID (only with `create_gateway`)."
  type        = string
  default     = null
}

variable "cloudflare_api_token_secret" {
  description = "GCP Secret Manager secret ID with the Cloudflare API token (only with `create_gateway`)."
  type        = string
  default     = null
}
