local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('ArgoCdAppOutOfSync')
+ rule.withExpr(|||
  sum(
    argocd_app_info{
      job=~".*",
      sync_status!="Synced"
    }
  ) by (cluster, job, dest_server, project, name, sync_status)
  > 0
|||)
+ rule.withFor('15m')
+ rule.withLabels({ severity: 'warning' })
+ rule.withAnnotations({
  summary: 'An ArgoCD Application is Out Of Sync.',
  description: 'The application {{ $labels.dest_server }}/{{ $labels.project }}/{{ $labels.name }} is out of sync with the sync status {{ $labels.sync_status }} for the past 15m.',
  dashboard_url: 'https://grafana.com/d/argo-cd-application-overview-kask/argocd-application-overview?var-dest_server={{ $labels.dest_server }}&var-project={{ $labels.project }}&var-application={{ $labels.name }}',
})
