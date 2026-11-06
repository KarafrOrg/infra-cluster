local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local group = prometheusRule.spec.groups;

prometheusRule.new('cert-manager')
+ prometheusRule.spec.withGroups([
  group.withName('cert-manager')
  + group.withRules([
    import 'absent.jsonnet',
  ]),
])
