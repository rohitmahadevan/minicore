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
