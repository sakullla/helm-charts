{{/*
Expand the name of the chart.
*/}}
{{- define "headplane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "headplane.fullname" -}}
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
{{- define "headplane.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "headplane.labels" -}}
helm.sh/chart: {{ include "headplane.chart" . }}
{{ include "headplane.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "headplane.selectorLabels" -}}
app.kubernetes.io/name: {{ include "headplane.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "headplane.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "headplane.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "headscale.fullname.override" -}}
{{- /* 1. 获取 headscale子 Chart 的 Values (注意名称要和 Chart.yaml 里的依赖名称一致) */ -}}
{{- $headscaleValues := index .Values "headscale" -}}
{{- /* 2. 构造新的上下文，伪造 Chart Name */ -}}
{{- $headscaleContext := dict "Values" $headscaleValues "Release" .Release "Chart" (dict "Name" "headscale") "Template" .Template -}}
{{- /* 3. 调用子 Chart 的模板 */ -}}
{{- include "headscale.fullname" $headscaleContext -}}
{{- end -}}