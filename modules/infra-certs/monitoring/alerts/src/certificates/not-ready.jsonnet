local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('CertManagerCertNotReady')
+ rule.withExpr(|||
  max by (name, exported_namespace, namespace, condition) (
    certmanager_certificate_ready_status{condition!="True"} == 1
  )
|||)
+ rule.withFor('10m')
+ rule.withLabels({ severity: 'critical' })
+ rule.withAnnotations({
  summary: 'The cert `{{ $labels.name }}` is not ready to serve traffic.',
  description: 'This certificate has not been ready to serve traffic for at least 10m. If the cert is being renewed or there is another valid cert, the ingress controller _may_ be able to serve that instead.',
  runbook_url: 'https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagercertnotready',
})
