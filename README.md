# minicore

A small Helm chart written as a learning exercise. It renders one web
Deployment and Service for each enabled cluster entry in `values.yaml`, using
patterns common in multi-cluster charts: per-cluster loops, generated names,
cluster-then-common settings, and validated helpers.

It only renders plain Kubernetes objects, so everything can be tested with
`helm template`. No cluster is needed.

## Status

| Requirement | Description | State |
|---|---|---|
| R1 | One Deployment + Service per enabled cluster entry | done |
| R2 | Names `{release}-{cluster}-web` | done |
| R3 | Settings from the cluster's `web`, then `common.web` | done for `replicas` and `image`; `pod_anti_affinity` is used in R6 |
| R4 | `minicore/host: web.<region>.<domain>` annotation via `minicore.lib.regionName` | done; domain read from `common.domain` until R5 |
| R5 | `minicore.lib.domain`: fail on empty `common.domain` or old `common.cluster_domain` | to do |
| R6 | `minicore.lib.podAntiAffinity`: `required` / `preferred` / `none` | to do |
| R7 | Helpers in `_helpers.tpl`, loop in `web.yaml`, root saved as `$global` | done so far |

## Layout

```
Chart.yaml
values.yaml               common settings + one entry per cluster
templates/
  _helpers.tpl            minicore.lib.* helpers
  web.yaml                loops over clusters; Deployment + Service where web is enabled
```

## Values

```yaml
common:
  domain: ""                 # required
  region_name: ""            # fallback region for every cluster
  web:
    enabled_default: false   # used when a cluster leaves web.enabled unset or null
    image: nginx:1.27
    replicas: 2
    pod_anti_affinity: none  # required, preferred or none

clusters:
  <name>:
    enabled: true
    region_name: ""          # beats common.region_name; final default "global"
    web:
      enabled: true          # optional; overrides common.web.enabled_default
```

## `minicore.lib.webEnabled`

Called as `include "minicore.lib.webEnabled" (list $global $cluster)`.
Returns the string `true`, or an empty string.

| Cluster `enabled` | Has `web` | `web.enabled` | Result |
|---|---|---|---|
| false | any | any | off |
| true | no | n/a | off |
| true | yes | `true` | on |
| true | yes | `false` | off, even if `enabled_default` is true |
| true | yes | unset or `null` | `common.web.enabled_default` |

An explicit `false` must beat the default, so the helper uses `hasKey` and
`kindIs "invalid"` instead of `default`, which treats `false` as unset.

## Trying it

Each command lists the objects rendered, from inside the chart folder:

```
helm template demo . --set common.domain=kind.test | grep -E '^kind:|^  name:'
helm template demo . --set common.domain=kind.test --set common.web.enabled_default=true | grep -E '^kind:|^  name:'
helm template demo . --set common.domain=kind.test --set common.web.enabled_default=true --set clusters.mothership.web.enabled=false | grep -E '^kind:|^  name:'
helm template demo . --set common.domain=kind.test --set common.web.enabled_default=true --set clusters.edge.web.enabled=null | grep -E '^kind:|^  name:'
```

| Case | Objects |
|---|---|
| defaults | `demo-mothership-web` |
| `enabled_default=true` | `demo-edge-web`, `demo-mothership-web` |
| default true, mothership `false` | `demo-edge-web` |
| default true, edge `null` | `demo-edge-web`, `demo-mothership-web` |

Each name appears twice: one Deployment and one Service.
