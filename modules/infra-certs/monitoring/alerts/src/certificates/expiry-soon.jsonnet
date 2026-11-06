local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('CertManagerCertExpirySoon')
+ rule.withExpr(|||
  avg by (exported_namespace, namespace, name) (
    (certmanager_certificate_expiration_timestamp_seconds - time())
    and on (exported_namespace, namespace, name)
    (certmanager_certificate_ready_status{condition="True"} == 1)
  )
  <
  avg by (exported_namespace, namespace, name) (
    certmanager_certificate_expiration_timestamp_seconds - certmanager_certificate_renewal_timestamp_seconds
  ) * 0.7
|||)
+ rule.withFor('1h')
+ rule.withLabels({ severity: 'warning' })
+ rule.withAnnotations({
  summary: 'The cert `{{ $labels.name }}` is {{ $value | humanizeDuration }} from expiry, it should have been renewed by now.',
  description: 'The domain that this cert covers will be unavailable after {{ $value | humanizeDuration }}. Clients using endpoints that this cert protects will start to fail in {{ $value | humanizeDuration }}.',
  runbook_url: 'https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagercertexpirysoon',
})
