{{/*
Expand the name of the chart.
*/}}
{{- define "nginx-stream.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nginx-stream.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nginx-stream.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nginx-stream.labels" -}}
helm.sh/chart: {{ include "nginx-stream.chart" . }}
{{ include "nginx-stream.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nginx-stream.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nginx-stream.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nginx-stream.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nginx-stream.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create deterministic service/container port names from forward name + protocol.
Name length is configurable but always Kubernetes-safe.
*/}}
{{- define "nginx-stream.forwardPortName" -}}
{{- $requested := int (default 15 .root.Values.portName.maxLength) -}}
{{- $maxLen := $requested -}}
{{- if gt $maxLen 32 }}{{- $maxLen = 32 }}{{- end -}}
{{- if gt $maxLen 15 }}{{- $maxLen = 15 }}{{- end -}}
{{- if lt $maxLen 8 }}{{- $maxLen = 8 }}{{- end -}}
{{- $suffix := printf "-%s" .protocol -}}
{{- $baseMax := sub $maxLen (len $suffix) -}}
{{- if lt $baseMax 1 }}{{- $baseMax = 1 }}{{- end -}}
{{- $base := default (printf "fwd-%d" .index) .forwardName | lower -}}
{{- $base = regexReplaceAll "[^a-z0-9-]+" $base "-" -}}
{{- $base = trimAll "-" $base -}}
{{- if eq $base "" }}{{- $base = printf "fwd-%d" .index -}}{{- end -}}
{{- $base = trunc (int $baseMax) $base | trimSuffix "-" -}}
{{- if eq $base "" }}{{- $base = "f" -}}{{- end -}}
{{- printf "%s%s" $base $suffix -}}
{{- end -}}

{{/*
Find the first TCP listen port from nginx.forwards for probes/tests.
TCP is enabled by default unless explicitly set to false.
*/}}
{{- define "nginx-stream.firstTcpPort" -}}
{{- $port := "" -}}
{{- $tcpDefault := dig "protocolDefaults" "tcpEnabled" true .Values.nginx -}}
{{- range .Values.nginx.forwards }}
  {{- $tcpEnabled := dig "tcp" "enabled" $tcpDefault . -}}
  {{- $backendCount := include "nginx-stream.backendCount" (dict "forward" .) | int -}}
  {{- if and (empty $port) .listenPort $tcpEnabled (gt $backendCount 0) }}
    {{- $port = printf "%v" .listenPort -}}
  {{- end }}
{{- end }}
{{- $port -}}
{{- end -}}

{{/*
Whether any forward renders at least one Service port.
*/}}
{{- define "nginx-stream.hasForwardPorts" -}}
{{- $has := false -}}
{{- $tcpDefault := dig "protocolDefaults" "tcpEnabled" true .Values.nginx -}}
{{- $udpDefault := dig "protocolDefaults" "udpEnabled" true .Values.nginx -}}
{{- range .Values.nginx.forwards }}
  {{- $tcpEnabled := dig "tcp" "enabled" $tcpDefault . -}}
  {{- $udpEnabled := dig "udp" "enabled" $udpDefault . -}}
  {{- $backendCount := include "nginx-stream.backendCount" (dict "forward" .) | int -}}
  {{- if and .listenPort (gt $backendCount 0) (or $tcpEnabled $udpEnabled) }}
    {{- $has = true -}}
  {{- end }}
{{- end }}
{{- if $has }}true{{- end -}}
{{- end -}}

{{/*
Create deterministic upstream names from forward name.
*/}}
{{- define "nginx-stream.upstreamName" -}}
{{- $base := default (printf "fwd-%d" .index) .forwardName | lower -}}
{{- $base = regexReplaceAll "[^a-z0-9-]+" $base "-" -}}
{{- $base = trimAll "-" $base -}}
{{- if eq $base "" }}{{- $base = printf "fwd-%d" .index -}}{{- end -}}
{{- printf "up-%d-%s" .index $base | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Count valid backends for a forward. "backends" takes precedence over the legacy
backendHost/backendPort pair.
*/}}
{{- define "nginx-stream.backendHostValue" -}}
{{- $backend := .backend -}}
{{- $endpoint := coalesce $backend.address $backend.host "" -}}
{{- $host := $endpoint -}}
{{- if regexMatch "^\\[[^\\]]+\\]:[0-9]+$" $endpoint -}}
  {{- $host = trimAll "[]" (regexFind "^\\[[^\\]]+\\]" $endpoint) -}}
{{- else if regexMatch "^[^:]+:[0-9]+$" $endpoint -}}
  {{- $host = regexReplaceAll ":[0-9]+$" $endpoint "" -}}
{{- end -}}
{{- $host -}}
{{- end -}}

{{- define "nginx-stream.backendPortValue" -}}
{{- $forward := .forward -}}
{{- $backend := .backend -}}
{{- $endpoint := coalesce $backend.address $backend.host "" -}}
{{- $parsedPort := "" -}}
{{- if regexMatch "^\\[[^\\]]+\\]:[0-9]+$" $endpoint -}}
  {{- $parsedPort = regexFind "[0-9]+$" $endpoint -}}
{{- else if regexMatch "^[^:]+:[0-9]+$" $endpoint -}}
  {{- $parsedPort = regexFind "[0-9]+$" $endpoint -}}
{{- end -}}
{{- coalesce $backend.port $parsedPort $forward.backendPort "" -}}
{{- end -}}

{{- define "nginx-stream.backendCount" -}}
{{- $count := 0 -}}
{{- $forward := .forward -}}
{{- if $forward.backends -}}
  {{- range $forward.backends -}}
    {{- $host := include "nginx-stream.backendHostValue" (dict "backend" .) -}}
    {{- $port := include "nginx-stream.backendPortValue" (dict "forward" $forward "backend" .) -}}
    {{- if and $host $port -}}
      {{- $count = add $count 1 -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{- $legacy := dict "address" $forward.backendHost -}}
  {{- $host := include "nginx-stream.backendHostValue" (dict "backend" $legacy) -}}
  {{- $port := include "nginx-stream.backendPortValue" (dict "forward" $forward "backend" $legacy) -}}
  {{- if and $host $port -}}
  {{- $count = 1 -}}
  {{- end -}}
{{- end -}}
{{- $count -}}
{{- end -}}

{{/*
Whether a backend host should use runtime DNS re-resolution.
*/}}
{{- define "nginx-stream.backendNeedsResolve" -}}
{{- $backend := .backend -}}
{{- if hasKey $backend "resolve" -}}
  {{- if $backend.resolve }}true{{- end -}}
{{- else -}}
  {{- $host := include "nginx-stream.backendHostValue" (dict "backend" $backend) | trimAll "[]" -}}
  {{- if and $host (not (regexMatch "^([0-9]{1,3}\\.){3}[0-9]{1,3}$" $host)) (not (regexMatch "^[0-9A-Fa-f:]+$" $host)) }}true{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Render a single stream upstream backend entry.
*/}}
{{- define "nginx-stream.renderStreamBackend" -}}
{{- $forward := .forward -}}
{{- $backend := .backend -}}
{{- $host := include "nginx-stream.backendHostValue" (dict "backend" $backend) -}}
{{- $port := include "nginx-stream.backendPortValue" (dict "forward" $forward "backend" $backend) -}}
{{- if and $host $port -}}
server {{ $host }}:{{ $port }}{{- with $backend.weight }} weight={{ . }}{{- end }}{{- if include "nginx-stream.backendNeedsResolve" (dict "backend" $backend) }} resolve{{- end }};
{{- end -}}
{{- end -}}

{{/*
Render a stream upstream block for a forward.
*/}}
{{- define "nginx-stream.renderStreamUpstream" -}}
{{- $index := .index -}}
{{- $forward := .forward -}}
{{- $backendCount := include "nginx-stream.backendCount" (dict "forward" $forward) | int -}}
{{- if gt $backendCount 0 -}}
{{- $upstreamName := include "nginx-stream.upstreamName" (dict "index" $index "forwardName" $forward.name) -}}
{{- $strategy := dig "loadBalancing" "strategy" "round_robin" $forward | lower -}}
{{- if and (ne $strategy "round_robin") (ne $strategy "least_conn") (ne $strategy "random") (ne $strategy "hash") -}}
{{- fail (printf "nginx.forwards[%d].loadBalancing.strategy must be one of round_robin, least_conn, random, hash" $index) -}}
{{- end -}}
{{- $hashKey := dig "loadBalancing" "hashKey" "" $forward -}}
{{- if and (eq $strategy "hash") (not $hashKey) -}}
{{- fail (printf "nginx.forwards[%d].loadBalancing.hashKey is required when strategy=hash" $index) -}}
{{- end -}}
upstream {{ $upstreamName }} {
  zone {{ $upstreamName }} {{ dig "loadBalancing" "zoneSize" "64k" $forward }};
{{- if eq $strategy "least_conn" }}
  least_conn;
{{- else if eq $strategy "random" }}
  random;
{{- else if eq $strategy "hash" }}
  hash {{ $hashKey }};
{{- end }}
{{- if $forward.backends }}
{{- range $forward.backends }}
{{ include "nginx-stream.renderStreamBackend" (dict "forward" $forward "backend" .) | nindent 2 }}
{{- end }}
{{- else }}
{{ include "nginx-stream.renderStreamBackend" (dict "forward" $forward "backend" (dict "address" $forward.backendHost)) | nindent 2 }}
{{- end }}
}
{{- end -}}
{{- end -}}
