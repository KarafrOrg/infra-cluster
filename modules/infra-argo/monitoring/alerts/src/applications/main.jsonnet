local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local group = prometheusRule.spec.groups;

prometheusRule.new('argocd-applications')
+ prometheusRule.spec.withGroups([
  group.withName('argocd-applications')
  + group.withRules([
    import 'app-sync-failed.jsonnet',
    import 'app-unhealthy.jsonnet',
    import 'app-out-of-sync.jsonnet',
    import 'app-auto-sync-disabled.jsonnet',
  ]),
])
