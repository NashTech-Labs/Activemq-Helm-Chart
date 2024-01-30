# Check if broker is secured
{{ define "secure_broker.isDefined" }}
{{- if or (eq (toString .enabled) "true") (eq ( toString .enabled) "false") }}
{{- .enabled }}
{{- else }}
{{ if empty .enabled }}
{{ fail "Value 'secure_broker' should not be empty"}}
{{ else }}
{{ fail (printf "Unexpected value %s for 'secure_broker'. Expected boolean value true or false" .enabled) }}
{{ end }}
{{- end }}
{{- end }}


# Check if password is minimum 8 letters length
{{ define "password.isValid" }}
{{- if empty .password }}
{{ fail "Password cannot be empty" }}
{{- else if le (len .password) 8 }}
{{ fail "Password length must be a minimum of 8 characters"}}
{{- end }}
{{- .password }}
{{- end }}


# Set pod anti affinity
{{ define "activemq.podantiaffinity" }}
{{- with .Values.deployment.affinity }}
{{- if eq .pod_anti_affinity "default" }}
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: "kubernetes.io/hostname"
      labelSelector:
        matchLabels:
          io.kubernetes/app-name: {{ $.Release.Name }}-activemq
          io.activemq/version: "5.10"
{{- else if eq .pod_anti_affinity "custom" }}
podAntiAffinity: {{.podAntiAffinity | toYaml | nindent 2 }}
{{- else if ne .pod_anti_affinity "disabled" }}
{{ fail "Value of pod Anti affinity should either be default, custom or disabled"}}
{{- end }}
{{- end }}
{{- end }}

{{ define "web.proxy" }}
{{- with .Values.deployment }}
{{- if not .standalone }}
{{- range $k,$v := until (int .replicas) }}
server {{ $.Release.Name }}-activemq-{{ $k }}.{{ $.Release.Name}}-activemq.{{ $.Release.Namespace }}.svc.cluster.local:8161 max_fails=1 fail_timeout=5s;
{{- end }}
{{ else }}
server {{ $.Release.Name }}-activemq-0.{{ $.Release.Name}}-activemq.{{ $.Release.Namespace }}.svc.cluster.local:8161 max_fails=1 fail_timeout=5s;
{{- end }}
{{- end }}
{{- end }}

{{ define "activemq.secret" }}
{{- with .Values.activemq }}
{{- if .external_secret.enabled }}
{{- if not .external_secret.secrets }}
{{- fail "Secrets must be passed if external_secret is enabled" }}
{{- end }}
{{- if eq (len .external_secret.secrets ) 0 }}
{{- fail "Secrets must be passed if external_secret is enabled" }}
{{- end }}
{{- range .external_secret.secrets }}
- secretRef:
    name: {{ . }}
{{- end }}
{{- else }}
{{- if eq ( include "secure_broker.isDefined" .secure_broker ) "true" }}
- secretRef:
    name: {{ $.Release.Name }}-activemq-broker-secrets
- secretRef:
    name: {{ $.Release.Name }}-activemq-ui-secrets
{{- else }}
- secretRef:
    name: {{ $.Release.Name }}-activemq-ui-secrets
{{- end }}
{{- if .datastore.sql }}
- secretRef:
    name: {{ $.Release.Name }}-activemq-sql-datastore-secrets
{{- end }}
{{- end }}
{{- end }}
{{- end }}

