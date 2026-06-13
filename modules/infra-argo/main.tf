resource "helm_release" "argo_cd" {
  chart      = "argo-cd"
  name       = var.argo_cd_helm_release_name
  repository = var.argo_cd_helm_release_repository
  values = [
    templatefile("${path.module}/templates/values/argo_cd/values.tftpl.yaml", {
      argocd_ingress_domain          = var.argocd_ingress_domain,
      argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.argo_cd_helm_release_namespace
}
