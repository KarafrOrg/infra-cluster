local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('ArgoCdAppAutoSyncDisabled')
+ rule.withExpr(|||
  sum(
    argocd_app_info{
      job=~".*",
      autosync_enabled!="true",
      name!~""
    }
  ) by (cluster, job, dest_server, project, name, autosync_enabled)
  > 0
|||)
+ rule.withFor('2h')
+ rule.withLabels({ severity: 'warning' })
+ rule.withAnnotations({
  summary: 'An ArgoCD Application has AutoSync Disabled.',
  description: 'The application {{ $labels.dest_server }}/{{ $labels.project }}/{{ $labels.name }} has autosync disabled for the past 2h.',
  dashboard_url: 'https://grafana.com/d/argo-cd-application-overview-kask/argocd-application-overview?var-dest_server={{ $labels.dest_server }}&var-project={{ $labels.project }}&var-application={{ $labels.name }}',
})
