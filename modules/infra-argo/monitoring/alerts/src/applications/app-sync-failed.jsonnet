local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('ArgoCdAppSyncFailed')
+ rule.withExpr(|||
  sum(
    round(
      increase(
        argocd_app_sync_total{
          job=~".*",
          phase!="Succeeded"
        }[10m]
      )
    )
  ) by (cluster, job, dest_server, project, name, phase) > 0
|||)
+ rule.withFor('1m')
+ rule.withLabels({ severity: 'warning' })
+ rule.withAnnotations({
  summary: 'An ArgoCD Application has Failed to Sync.',
  description: 'The application {{ $labels.dest_server }}/{{ $labels.project }}/{{ $labels.name }} has failed to sync with the status {{ $labels.phase }} the past 10m.',
  dashboard_url: 'https://grafana.com/d/argo-cd-application-overview-kask/argocd-application-overview?var-dest_server={{ $labels.dest_server }}&var-project={{ $labels.project }}&var-application={{ $labels.name }}',
})
