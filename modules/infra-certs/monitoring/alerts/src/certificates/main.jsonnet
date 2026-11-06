local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local group = prometheusRule.spec.groups;

prometheusRule.new('cert-manager-certificates')
+ prometheusRule.spec.withGroups([
  group.withName('cert-manager-certificates')
  + group.withRules([
    import 'expiry-soon.jsonnet',
    import 'not-ready.jsonnet',
    import 'hitting-rate-limits.jsonnet',
  ]),
])
