local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('ArgoCdAppUnhealthy')
+ rule.withExpr(|||
  sum(
    argocd_app_info{
      job=~".*",
      health_status!~"Healthy|Progressing",
      name!~""
    }
  ) by (cluster, job, dest_server, project, name, health_status)
  > 0
|||)
+ rule.withFor('15m')
+ rule.withLabels({ severity: 'warning' })
+ rule.withAnnotations({
  summary: 'An ArgoCD Application is Unhealthy.',
  description: 'The application {{ $labels.dest_server }}/{{ $labels.project }}/{{ $labels.name }} is unhealthy with the health status {{ $labels.health_status }} for the past 15m.',
  dashboard_url: 'https://grafana.com/d/argo-cd-application-overview-kask/argocd-application-overview?var-dest_server={{ $labels.dest_server }}&var-project={{ $labels.project }}&var-application={{ $labels.name }}',
})
