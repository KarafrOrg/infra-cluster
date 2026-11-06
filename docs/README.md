# infra-cluster

Argo CD's `jsonnet-bundler` config management plugin detects application roots
with a `jsonnetfile.json`, runs `jb install`, and renders `main.jsonnet` with
`jsonnet -J vendor`. Jsonnet applications must include both files at the
application root and should commit `jsonnetfile.lock.json` to pin dependencies.
The repo-server init container installs pinned Jsonnet and Jsonnet Bundler
versions from Go modules at startup. `jb install` also needs network access to
Jsonnet package sources during manifest generation.
