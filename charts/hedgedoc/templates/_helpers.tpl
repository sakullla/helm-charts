{{/*
Expand the name of the chart.
*/}}
{{- define "hedgedoc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hedgedoc.fullname" -}}
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
{{- define "hedgedoc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hedgedoc.labels" -}}
helm.sh/chart: {{ include "hedgedoc.chart" . }}
{{ include "hedgedoc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hedgedoc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hedgedoc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hedgedoc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hedgedoc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/* 这是一个全局辅助文件，define 必须放在这里或文件顶层 */}}

{{- define "hedgedoc-backend.fullname.override" -}}
{{- /* 1. 获取 hedgedoc-backend 子 Chart 的 Values (注意名称要和 Chart.yaml 里的依赖名称一致) */ -}}
{{- $hedgedocBackendValues := index .Values "hedgedoc-backend" -}}
{{- /* 2. 构造新的上下文，伪造 Chart Name */ -}}
{{- $hedgedocBackendContext := dict "Values" $hedgedocBackendValues "Release" .Release "Chart" (dict "Name" "hedgedoc-backend") "Template" .Template -}}
{{- /* 3. 调用子 Chart 的模板 */ -}}
{{- include "hedgedoc-backend.fullname" $hedgedocBackendContext -}}
{{- end -}}
