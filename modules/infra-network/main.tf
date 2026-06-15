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
resource "helm_release" "gateway_api_crds" {
  count            = var.gateway_api.enabled ? 1 : 0
  name             = "gateway-api"
  repository       = "oci://ghcr.io/nicklasfrahm/charts"
  chart            = "gateway-api"
  version          = var.gateway_api.gateway_api_crds_version
  upgrade_install  = true
  create_namespace = true
  namespace        = "gateway-system"
  timeout          = 300
  wait             = true
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
    helm_release.gateway_api_crds,
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

// region Istio

resource "helm_release" "istio_base" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.istio.release_namespace
  values = [
    templatefile("${path.module}/templates/values/istio/base.tftpl.yaml", {
      istio_namespace = var.istio.release_namespace
    })
  ]
}

resource "helm_release" "istio_istiod" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.istio.release_namespace
  values = [
    templatefile("${path.module}/templates/values/istio/istiod.tftpl.yaml", {
      istio_namespace = var.istio.release_namespace
      tracing_service = var.istio.tracing_service
      tracing_port    = var.istio.tracing_port
    })
  ]
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_cni" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istio-cni"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "cni"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.istio.release_namespace
  values = [
    templatefile("${path.module}/templates/values/istio/cni.tftpl.yaml", {
      istio_namespace = var.istio.release_namespace
      cni_platform    = var.istio.cni_platform
    })
  ]
  depends_on = [helm_release.istio_istiod]
}

resource "helm_release" "istio_ztunnel" {
  count            = var.istio.enabled ? 1 : 0
  name             = "ztunnel"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "ztunnel"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.istio.release_namespace
  values = [
    templatefile("${path.module}/templates/values/istio/ztunnel.tftpl.yaml", {
      istio_namespace = var.istio.release_namespace
    })
  ]
  depends_on = [helm_release.istio_istiod]
}

resource "helm_release" "istio_gateway" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istio-gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.istio.release_namespace
  values           = [file("${path.module}/templates/values/istio/gateway.yaml")]
  depends_on       = [helm_release.istio_istiod]
}

resource "kubectl_manifest" "istio_ingress_gateway_certificate" {
  count = var.istio.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/istio/public-ingress-gateway-certificate.tftmpl.yaml", {
    istio_namespace  = var.istio.release_namespace
    ingress_domain   = var.istio.ingress_domain
    cert_issuer_name = var.istio.cert_issuer_name
  })
  depends_on = [helm_release.istio_istiod]
}

resource "kubectl_manifest" "istio_public_ingress_gateway" {
  count = var.istio.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/istio/public-ingress-gateway.tftmpl.yaml", {
    istio_namespace = var.istio.release_namespace
    ingress_domain  = var.istio.ingress_domain
  })
  depends_on = [
    helm_release.istio_gateway,
    kubectl_manifest.istio_ingress_gateway_certificate,
  ]
}

// endregion

// region cloudflared DaemonSet
resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  count      = var.cloudflared.enabled ? 1 : 0
  account_id = var.cloudflared.account_id
  name       = var.cloudflared.tunnel_name
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  count      = var.cloudflared.enabled ? 1 : 0
  account_id = var.cloudflared.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this[0].id
}

resource "google_secret_manager_secret" "cloudflared_tunnel_token" {
  count     = var.cloudflared.enabled ? 1 : 0
  project   = var.gcp_project_id
  secret_id = var.cloudflared.tunnel_token_secret
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "cloudflared_tunnel_token" {
  count       = var.cloudflared.enabled ? 1 : 0
  secret      = google_secret_manager_secret.cloudflared_tunnel_token[0].id
  secret_data = data.cloudflare_zero_trust_tunnel_cloudflared_token.this[0].token
}

resource "kubectl_manifest" "cloudflared_external_secret" {
  count = var.cloudflared.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflared/external-secret.tftmpl.yaml", {
    cloudflared_namespace          = var.cloudflared.namespace
    cloudflare_tunnel_token_secret = var.cloudflared.tunnel_token_secret
  })
  depends_on = [
    kubectl_manifest.cloudflare_gateway_namespace,
    google_secret_manager_secret_version.cloudflared_tunnel_token,
  ]
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
