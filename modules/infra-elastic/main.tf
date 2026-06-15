// region ECK Operator

resource "helm_release" "eck_operator" {
  count      = var.eck_operator.enabled ? 1 : 0
  chart      = "eck-operator"
  name       = var.eck_operator.release_name
  repository = var.eck_operator.release_repository
  values     = [file("${path.module}/templates/values/eck_operator/values.yaml")]

  upgrade_install  = true
  create_namespace = true
  timeout          = 600
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.eck_operator.release_namespace
}

// endregion
