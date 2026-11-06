local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('CertManagerHittingRateLimits')
+ rule.withExpr(|||
  sum by (host) (
    rate(certmanager_http_acme_client_request_count{status="429"}[5m])
  ) > 0
|||)
+ rule.withFor('5m')
+ rule.withLabels({ severity: 'critical' })
+ rule.withAnnotations({
  summary: 'Cert manager hitting LetsEncrypt rate limits.',
  description: 'Depending on the rate limit, cert-manager may be unable to generate certificates for up to a week.',
  runbook_url: 'https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagerhittingratelimits',
})
