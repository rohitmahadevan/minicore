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