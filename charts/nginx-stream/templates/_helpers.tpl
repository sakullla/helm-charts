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
  {{- if and (empty $port) .listenPort $tcpEnabled }}
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
  {{- if and .listenPort (or $tcpEnabled $udpEnabled) }}
    {{- $has = true -}}
  {{- end }}
{{- end }}
{{- if $has }}true{{- end -}}
{{- end -}}
