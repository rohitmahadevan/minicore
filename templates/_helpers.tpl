{{- define "minicore.lib.webEnabled" -}}
{{- $global := index . 0 -}}
{{- $cluster := index . 1 -}}
{{- if and $cluster.enabled (hasKey $cluster "web") -}}
  {{- if and (hasKey $cluster.web "enabled") (not (kindIs "invalid" $cluster.web.enabled)) -}}
    {{- if $cluster.web.enabled -}}true{{- end -}}
  {{- else -}}
    {{- if $global.Values.common.web.enabled_default -}}true{{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "minicore.lib.regionName" -}}
{{- $global := index . 0 -}}
{{- $cluster := index . 1 -}}
{{- $cluster.region_name | default $global.Values.common.region_name | default "global" -}}
{{- end -}}

{{- define "minicore.lib.domain" -}}
{{- $global := index . 0 -}}
{{- if hasKey $global.Values.common "cluster_domain" -}}
  {{- fail "common.cluster_domain was replaced by common.domain" -}}
{{- end -}}
{{- required "common.domain is empty" $global.Values.common.domain -}}
{{- end -}}

{{- define "minicore.lib.podAntiAffinity" -}}
{{- $mode := index . 0 -}}
{{- $matchLabels := index . 1 -}}
{{- $replicas := int (index . 2) -}}
{{- $valuePath := index . 3 -}}
{{- if not (has $mode (list "required" "preferred" "none")) -}}
  {{- fail (printf "%s must be one of required, preferred or none, got %q" $valuePath $mode) -}}
{{- end -}}
{{- if gt $replicas 1 -}}
{{- if eq $mode "required" }}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        {{- toYaml $matchLabels | nindent 8 }}
    topologyKey: kubernetes.io/hostname
{{- else if eq $mode "preferred" }}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchLabels:
          {{- toYaml $matchLabels | nindent 10 }}
      topologyKey: kubernetes.io/hostname
{{- end -}}
{{- end -}}
{{- end -}}
