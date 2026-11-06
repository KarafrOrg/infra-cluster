local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('CertManagerAbsent')
+ rule.withExpr('absent(up{job="cert-manager"})')
+ rule.withFor('10m')
+ rule.withLabels({ severity: 'critical' })
+ rule.withAnnotations({
  summary: 'Cert Manager has disappeared from Prometheus service discovery.',
  description: "New certificates will not be able to be minted, and existing ones can't be renewed until cert-manager is back.",
  runbook_url: 'https://github.com/imusmanmalik/cert-manager-mixin/blob/main/RUNBOOK.md#certmanagerabsent',
})
