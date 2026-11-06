local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local group = prometheusRule.spec.groups;

prometheusRule.new('argocd-notifications')
+ prometheusRule.spec.withGroups([
  group.withName('argocd-notifications')
  + group.withRules([
    import 'notification-delivery-failed.jsonnet',
  ]),
])
