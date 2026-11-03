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

// region Namespaces
resource "kubectl_manifest" "cloudflare_gateway_namespace" {
  count = var.cloudflare_gateway_controller.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/namespace.tftmpl.yaml", {
    infra_network_namespace = var.cloudflare_gateway_controller.release_namespace
  })
}

resource "kubectl_manifest" "istio_namespace" {
  count = var.istio.enabled && (
    !var.cloudflare_gateway_controller.enabled ||
    var.istio.release_namespace != var.cloudflare_gateway_controller.release_namespace
  ) ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/namespace.tftmpl.yaml", {
    infra_network_namespace = var.istio.release_namespace
  })
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
  create_namespace = false
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
  depends_on = [
    kubectl_manifest.cloudflare_gateway_namespace,
    kubectl_manifest.istio_namespace,
  ]
}

resource "helm_release" "istio_istiod" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = false
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
  depends_on = [
    helm_release.istio_base,
    kubectl_manifest.cloudflare_gateway_namespace,
    kubectl_manifest.istio_namespace,
  ]
}

resource "helm_release" "istio_cni" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istio-cni"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "cni"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = false
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
  depends_on = [
    helm_release.istio_istiod,
    kubectl_manifest.cloudflare_gateway_namespace,
    kubectl_manifest.istio_namespace,
  ]
}

resource "helm_release" "istio_ztunnel" {
  count            = var.istio.enabled ? 1 : 0
  name             = "ztunnel"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "ztunnel"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = false
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
  depends_on = [
    helm_release.istio_istiod,
    kubectl_manifest.cloudflare_gateway_namespace,
    kubectl_manifest.istio_namespace,
  ]
}

resource "helm_release" "istio_gateway" {
  count            = var.istio.enabled ? 1 : 0
  name             = "istio-gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = var.istio.version
  upgrade_install  = true
  create_namespace = false
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

// region Cloudflare Gateway Controller (matheuscscp/cloudflare-gateway-controller)
resource "kubectl_manifest" "cloudflare_gateway_controller_external_secret" {
  count = var.cloudflare_gateway_controller.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflare_gateway_controller/external-secret.tftmpl.yaml", {
    namespace                    = var.cloudflare_gateway_controller.release_namespace
    cloudflare_account_id_secret = var.cloudflare_gateway_controller.cloudflare_account_id_secret
    cloudflare_api_token_secret  = var.cloudflare_gateway_controller.cloudflare_api_token_secret
  })
  depends_on = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "helm_release" "cloudflare_gateway_controller" {
  count     = var.cloudflare_gateway_controller.enabled ? 1 : 0
  chart     = "oci://ghcr.io/matheuscscp/charts/cloudflare-gateway-controller"
  name      = var.cloudflare_gateway_controller.release_name
  version   = var.cloudflare_gateway_controller.chart_version
  namespace = var.cloudflare_gateway_controller.release_namespace
  values = [
    templatefile("${path.module}/templates/values/cloudflare_gateway_controller/values.tftpl.yaml", {
      cluster_name = var.cloudflare_gateway_controller.cluster_name
      replicas     = var.cloudflare_gateway_controller.controller_replicas
    })
  ]
  skip_crds       = true # Gateway API CRDs are already installed in the cluster
  upgrade_install = true
  timeout         = 900
  wait            = true
  cleanup_on_fail = true
  atomic          = true
  depends_on      = [kubectl_manifest.cloudflare_gateway_namespace]
}

resource "kubectl_manifest" "cloudflare_gateway_controller_gatewayclass" {
  count = var.cloudflare_gateway_controller.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflare_gateway_controller/gatewayclass.tftmpl.yaml", {
    namespace          = var.cloudflare_gateway_controller.release_namespace
    gateway_class_name = var.cloudflare_gateway_controller.gateway_class_name
  })
  depends_on = [
    helm_release.cloudflare_gateway_controller,
    kubectl_manifest.cloudflare_gateway_controller_external_secret,
  ]
}

resource "kubectl_manifest" "cloudflare_gateway_controller_parameters" {
  count = var.cloudflare_gateway_controller.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflare_gateway_controller/parameters.tftmpl.yaml", {
    namespace    = var.cloudflare_gateway_controller.release_namespace
    gateway_name = var.cloudflare_gateway_controller.gateway_name
    replicas     = var.cloudflare_gateway_controller.tunnel_replicas
  })
  depends_on = [helm_release.cloudflare_gateway_controller]
}

resource "kubectl_manifest" "cloudflare_gateway_controller_reference_grant" {
  count = var.cloudflare_gateway_controller.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflare_gateway_controller/reference-grant.tftmpl.yaml", {
    namespace       = var.cloudflare_gateway_controller.release_namespace
    from_namespaces = var.cloudflare_gateway_controller.credential_reference_namespaces
  })
  depends_on = [helm_release.cloudflare_gateway_controller]
}

resource "kubectl_manifest" "cloudflare_gateway_controller_gateway" {
  count = var.cloudflare_gateway_controller.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/cloudflare_gateway_controller/gateway.tftmpl.yaml", {
    namespace          = var.cloudflare_gateway_controller.release_namespace
    gateway_name       = var.cloudflare_gateway_controller.gateway_name
    gateway_class_name = var.cloudflare_gateway_controller.gateway_class_name
  })
  depends_on = [
    kubectl_manifest.cloudflare_gateway_controller_gatewayclass,
    kubectl_manifest.cloudflare_gateway_controller_parameters,
  ]
}
// endregion
