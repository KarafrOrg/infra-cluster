locals {
  proxy_name   = "${var.name}-frontend-proxy"
  gateway_name = coalesce(var.gateway_name, var.name)
  app_name     = coalesce(var.app_name, var.name)
}

resource "kubectl_manifest" "gateway_external_secret" {
  count = var.create_gateway && var.private_gateway == null ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/gateway-external-secret.tftpl.yaml", {
    name                         = var.name
    namespace                    = var.namespace
    cloudflare_account_id_secret = var.cloudflare_account_id_secret
    cloudflare_api_token_secret  = var.cloudflare_api_token_secret
  })
}

resource "kubectl_manifest" "gateway_parameters" {
  count = var.create_gateway && var.private_gateway == null ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/gateway-parameters.tftpl.yaml", {
    name      = var.name
    namespace = var.namespace
    replicas  = var.tunnel_replicas
  })
  depends_on = [kubectl_manifest.gateway_external_secret]
}

resource "kubectl_manifest" "gateway" {
  count = var.create_gateway && var.private_gateway == null ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/gateway.tftpl.yaml", {
    name               = var.name
    namespace          = var.namespace
    gateway_class_name = var.gateway_class_name
  })
  depends_on = [kubectl_manifest.gateway_parameters]
}

locals {
  proxy_vars = {
    name          = local.proxy_name
    namespace     = var.namespace
    envoy_version = var.envoy_version
    faro_version  = var.faro_version
    faro_path     = var.faro_path
    faro_host     = var.faro_host
    faro_port     = var.faro_port
    upstream_host = var.upstream_host
    upstream_port = var.upstream_port
    app_name      = local.app_name
    app_namespace = var.namespace
    environment   = var.environment
  }
}

resource "kubectl_manifest" "frontend_proxy_config" {
  yaml_body = templatefile("${path.module}/templates/frontend-proxy-configmap.tftpl.yaml", local.proxy_vars)
}

resource "kubectl_manifest" "frontend_proxy_deployment" {
  yaml_body = templatefile("${path.module}/templates/frontend-proxy-deployment.tftpl.yaml", merge(local.proxy_vars, {
    config_hash = sha256(kubectl_manifest.frontend_proxy_config.yaml_body)
  }))
}

resource "kubectl_manifest" "frontend_proxy_service" {
  yaml_body = templatefile("${path.module}/templates/frontend-proxy-service.tftpl.yaml", local.proxy_vars)
}

resource "kubectl_manifest" "httproute" {
  yaml_body = templatefile("${path.module}/templates/httproute.tftpl.yaml", {
    name         = var.name
    namespace    = var.namespace
    gateway_name = local.gateway_name
    private      = var.private_gateway
    hostnames    = var.hostnames
    proxy_name   = local.proxy_name
  })
  depends_on = [kubectl_manifest.gateway, kubectl_manifest.frontend_proxy_deployment, kubectl_manifest.frontend_proxy_service]
}
