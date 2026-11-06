local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local rule = po.monitoring.v1.prometheusRule.spec.groups.rules;

rule.withAlert('ArgoCdNotificationDeliveryFailed')
+ rule.withExpr(|||
  sum(
    round(
      increase(
        argocd_notifications_deliveries_total{
          job=~".*",
          succeeded!="true"
        }[10m]
      )
    )
  ) by (cluster, job, exported_service, succeeded) > 0
|||)
+ rule.withFor('1m')
+ rule.withLabels({ severity: 'warning' })
+ rule.withAnnotations({
  summary: 'ArgoCD Notification Delivery Failed.',
  description: 'The notification job {{ $labels.job }} has failed to deliver to {{ $labels.exported_service }} for the past 10m.',
  dashboard_url: 'https://grafana.com/d/argo-cd-notifications-overview-kask/argocd-notifications-overview?var-job={{ $labels.job }}&var-exported_service={{ $labels.exported_service }}',
})
