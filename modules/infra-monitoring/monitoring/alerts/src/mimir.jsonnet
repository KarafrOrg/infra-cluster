local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';

local config = mixin {
  _config+:: {
    cortex_p99_latency_threshold_seconds: 10,
    // The rollout-operator mixin reads these flags from its own config scope, which the Mimir mixin does not populate.
    rollout_operator_zpdb_config_observer_alert_enabled: false,
    rollout_operator_replica_template_observer_alert_enabled: false,
  },
};

local groups =
  config.prometheusAlerts.groups
  + (if std.objectHasAll(config, 'prometheusRules') then config.prometheusRules.groups else []);

local excludes = [
  'MimirStrongConsistencyOffsetMissing',
];

prometheusRule.new('mimir')
+ prometheusRule.spec.withGroups([
  group { rules: [rule for rule in group.rules if !std.objectHas(rule, 'alert') || !std.member(excludes, rule.alert)] }
  for group in groups
])
