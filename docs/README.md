# infra-cluster

## Monitoring dashboards

Grafana provisions the Mimir overview, reads, writes, and queries dashboards from the Mimir mixin into the `infra/mimir` folder. Their cluster selector matches all clusters, including metrics without a cluster label; the Mimir datasource and `infra-monitoring` namespace selectors are hidden, and live refresh is enabled.

Grafana Explore also links Loki logs to the corresponding Mimir span-metric request rate when the log has a `service_name` and matching traced requests exist. The Grafana LLM plugin is installed and automatically enabled; an administrator must configure an LLM provider in the plugin before LLM features can be used. Configuring an external provider can send observability data to that provider.

Tempo links spans to Mimir request, error, and latency metrics, Loki trace-ID-matched logs, and Pyroscope span profiles. Spans with Kubernetes pod and namespace attributes also link to pod logs and an aggregate pod CPU profile, even without trace IDs in logs or span-profile instrumentation. Profile links require Pyroscope to be enabled; span-specific profiles additionally require instrumented profile IDs and matching samples. Metrics-to-trace exemplars and log-to-trace links require the corresponding trace IDs in the source data.

Argo CD's Jsonnet plugin caches completed dependency installations on the shared `argocd-jsonnet-cache` Longhorn volume, keyed by both Jsonnet dependency files and the bundler version. Projects with local dependencies or an existing vendor directory bypass the cache. A first install or a changed lockfile still requires network access; plugin execution and repo-server requests allow up to 15 minutes. The cache grows as dependency files change; old entries can be removed when no render is using them. Repo-server pods depend on the Longhorn RWX volume being available.

## Reloader

Reloader runs in `infra-cicd` and watches the cluster. Workloads opt in to rolling restarts when referenced ConfigMap data changes by adding this annotation to the workload's metadata (not the pod template):

```yaml
metadata:
  annotations:
    configmap.reloader.stakater.com/auto: "true"
```

For both ConfigMaps and Secrets use `reloader.stakater.com/auto: "true"` instead. Reloader patches the workload's pod template; Kubernetes then applies its rollout strategy. Argo CD self-healing can revert that patch unless the application is configured to ignore Reloader's changes. Disable the release with `reloader = { enabled = false }`.

## Blackbox Exporter

Blackbox Exporter runs in the monitoring namespace and its own metrics are scraped by Alloy. Its Deployment opts in to Reloader for changes to its referenced ConfigMap. No probe targets are configured by default. Configure targets through the `blackbox_exporter` variable in the live environment:

```hcl
blackbox_exporter = {
  targets = [
    { name = "example-http", url = "https://example.com/health" },
    { name = "example-tcp", url = "example.com:443", module = "tcp_connect" },
    { name = "github-status", url = "https://www.githubstatus.com/api/v2/status.json", module = "github_status" },
  ]
}
```

Target names must be unique Kubernetes resource names. The supported modules are `http_2xx` (default), `tcp_connect`, and `github_status`. The GitHub probe succeeds only when the status API returns valid JSON with `status.indicator` equal to `none`; degraded status, an unreachable API, or an invalid response fails the probe. It reflects GitHub's overall status indicator, not necessarily every reported incident. The chart creates a ServiceMonitor for each target, which Alloy discovers and forwards to Mimir. Probes originate inside the cluster; select targets accordingly. The in-cluster exporter also exposes `/probe?module=http_2xx&target=...` on port 9115.
