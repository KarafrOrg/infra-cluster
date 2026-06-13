// region MetalLB

resource "helm_release" "metallb" {
  count      = var.metallb.enabled ? 1 : 0
  chart      = "metallb"
  name       = var.metallb.release_name
  repository = var.metallb.release_repository
  values = [
    templatefile("${path.module}/templates/values/metallb/values.tftpl.yaml", {
      metallb_helm_release_namespace = var.metallb.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.metallb.release_namespace
}

resource "kubectl_manifest" "metallb_ip_pool" {
  count = var.metallb.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/metallb/ip-address-pool.tftmpl.yaml", {
    metallb_helm_release_namespace = var.metallb.release_namespace
    metallb_ip_pool_name           = local.metallb_ip_pool_name
    metallb_internal_cidr          = var.metallb.internal_cidr
  })
  depends_on = [helm_release.metallb]
}

resource "kubectl_manifest" "metallb_l2_advertisement" {
  count = var.metallb.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/metallb/l2-advertisement.tftmpl.yaml", {
    metallb_helm_release_namespace = var.metallb.release_namespace
    metallb_ip_pool_name           = local.metallb_ip_pool_name
  })
  depends_on = [kubectl_manifest.metallb_ip_pool]
}

// endregion

// region ExternalDNS

resource "kubectl_manifest" "external_dns_cloudflare_secret" {
  count = var.external_dns.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/external_dns/external-secret.tftmpl.yaml", {
    external_dns_helm_release_namespace = var.external_dns.release_namespace
    cloudflare_api_token_secret         = var.external_dns.cloudflare_api_token_secret
  })
}

resource "helm_release" "external_dns" {
  count      = var.external_dns.enabled ? 1 : 0
  chart      = "external-dns"
  name       = var.external_dns.release_name
  repository = var.external_dns.release_repository
  values = [
    templatefile("${path.module}/templates/values/external_dns/values.tftpl.yaml", {
      external_dns_helm_release_namespace = var.external_dns.release_namespace
      external_dns_domain_filter          = var.external_dns.domain_filter
      external_dns_txt_owner_id           = var.external_dns.txt_owner_id
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.external_dns.release_namespace
  depends_on       = [kubectl_manifest.external_dns_cloudflare_secret]
}
// endregion

// region Gateway API
data "http" "gateway_api_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api.gateway_api_crds_version}/standard-install.yaml"
}

data "kubectl_file_documents" "gateway_api_crds" {
  content = data.http.gateway_api_crds.response_body
}

resource "kubectl_manifest" "gateway_api_crds" {
  for_each  = var.gateway_api.enabled ? toset(data.kubectl_file_documents.gateway_api_crds.documents) : toset([])
  yaml_body = each.value
}

resource "kubectl_manifest" "cloudflare_gateway_namespace" {
  count = (var.gateway_api.enabled || var.cloudflared.enabled) ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/namespace.tftmpl.yaml", {
    cloudflare_namespace = local.cloudflare_namespace
  })
}

resource "kubectl_manifest" "cloudflare_gateway_external_secret" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/external-secret.tftmpl.yaml", {
    gateway_api_namespace        = var.gateway_api.namespace
    cloudflare_account_id_secret = var.gateway_api.cloudflare_account_id_secret
    cloudflare_api_token_secret  = var.gateway_api.cloudflare_api_token_secret
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflare_gateway_service_account" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/service-account.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflare_gateway_cluster_role" {
  count     = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/cluster-role.tftmpl.yaml", {})
}

resource "kubectl_manifest" "cloudflare_gateway_cluster_role_binding" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/cluster-role-binding.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_service_account]
}

resource "kubectl_manifest" "cloudflare_gateway_leader_election_role" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/leader-election-role.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflare_gateway_leader_election_role_binding" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/leader-election-role-binding.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [
    kubectl_manifest.cloudflare_gateway_leader_election_role,
    kubectl_manifest.cloudflare_gateway_service_account,
  ]
}

resource "kubectl_manifest" "cloudflare_gateway_metrics_service" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/metrics-service.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflare_gateway_image_metrics_service" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/image-metrics-service.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflare_gateway_controller" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/deployment.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
    gateway_api_version   = var.gateway_api.version
  })
  depends_on = [
    kubectl_manifest.cloudflare_gateway_service_account,
    kubectl_manifest.cloudflare_gateway_cluster_role_binding,
    kubectl_manifest.cloudflare_gateway_leader_election_role_binding,
    kubectl_manifest.gateway_api_crds,
  ]
}

resource "kubectl_manifest" "cloudflare_gatewayclass" {
  count = var.gateway_api.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/gatewayclass.tftmpl.yaml", {
    gateway_api_namespace = var.gateway_api.namespace
  })
  depends_on = [
    kubectl_manifest.cloudflare_gateway_controller,
    kubectl_manifest.cloudflare_gateway_external_secret,
  ]
}
// endregion

// region cloudflared DaemonSet
resource "kubectl_manifest" "cloudflared_external_secret" {
  count = var.cloudflared.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflared/external-secret.tftmpl.yaml", {
    cloudflared_namespace          = var.cloudflared.namespace
    cloudflare_tunnel_token_secret = var.cloudflared.tunnel_token_secret
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflared_daemonset" {
  count = var.cloudflared.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflared/daemonset.tftmpl.yaml", {
    cloudflared_namespace = var.cloudflared.namespace
    cloudflared_image     = var.cloudflared.image
  })
  depends_on = [kubectl_manifest.cloudflared_external_secret]
}
// endregion
