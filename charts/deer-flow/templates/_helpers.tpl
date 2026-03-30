{{/*
Expand the name of the chart.
*/}}
{{- define "deer-flow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "deer-flow.fullname" -}}
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
{{- define "deer-flow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "deer-flow.labels" -}}
helm.sh/chart: {{ include "deer-flow.chart" . }}
{{ include "deer-flow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "deer-flow.selectorLabels" -}}
app.kubernetes.io/name: {{ include "deer-flow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component-specific selector labels — args: list [componentName, rootContext]
*/}}
{{- define "deer-flow.componentSelectorLabels" -}}
{{- $component := index . 0 -}}
{{- $root := index . 1 -}}
app.kubernetes.io/name: {{ include "deer-flow.name" $root }}-{{ $component }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
{{- end }}

{{/*
Component-specific full labels — args: list [componentName, rootContext]
*/}}
{{- define "deer-flow.componentLabels" -}}
{{- $component := index . 0 -}}
{{- $root := index . 1 -}}
helm.sh/chart: {{ include "deer-flow.chart" $root }}
{{ include "deer-flow.componentSelectorLabels" . }}
{{- if $root.Chart.AppVersion }}
app.kubernetes.io/version: {{ $root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $root.Release.Service }}
{{- end }}

{{/*
Service account name
*/}}
{{- define "deer-flow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "deer-flow.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Internal gateway service URL (auto-wired DEER_FLOW_CHANNELS_GATEWAY_URL)
*/}}
{{- define "deer-flow.gatewayURL" -}}
{{- printf "http://%s-gateway:%d" (include "deer-flow.fullname" .) (.Values.gateway.service.port | int) }}
{{- end }}

{{/*
Internal langgraph service URL (auto-wired DEER_FLOW_CHANNELS_LANGGRAPH_URL)
*/}}
{{- define "deer-flow.langgraphURL" -}}
{{- printf "http://%s-langgraph:%d" (include "deer-flow.fullname" .) (.Values.langgraph.service.port | int) }}
{{- end }}

{{/*
DEER_FLOW_HOME path inside containers
*/}}
{{- define "deer-flow.homeDir" -}}
/app/backend/.deer-flow
{{- end }}
