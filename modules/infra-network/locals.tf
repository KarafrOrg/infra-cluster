locals {
  metallb_ip_pool_name = "internal-pool"
  cloudflare_namespace = var.gateway_api.enabled ? var.gateway_api.namespace : var.cloudflared.namespace

  _gateway_api_crd_docs = [
    for doc in split("\n---\n", data.http.gateway_api_crds.response_body) : trimspace(doc)
    if trimspace(doc) != "" && trimspace(doc) != "---"
  ]
}
