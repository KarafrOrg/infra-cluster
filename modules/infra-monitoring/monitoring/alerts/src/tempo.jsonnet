local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/grafana/tempo/operations/tempo-mixin/mixin.libsonnet';

prometheusRule.new('tempo')
+ prometheusRule.spec.withGroups(
  mixin.prometheusAlerts.groups
  + (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules.groups else [])
)
