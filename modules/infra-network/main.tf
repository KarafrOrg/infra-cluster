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
