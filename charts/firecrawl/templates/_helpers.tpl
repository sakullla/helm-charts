{{/*
Expand the name of the chart.
*/}}
{{- define "firecrawl.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "firecrawl.fullname" -}}
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
{{- define "firecrawl.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
common labels
*/}}
{{- define "firecrawl.labels" -}}
helm.sh/chart: {{ include "firecrawl.chart" . }}
{{ include "firecrawl.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector  labels
*/}}
{{- define "firecrawl.selectorLabels" -}}
app.kubernetes.io/name: {{ include "firecrawl.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
worker labels
*/}}
{{- define "worker.labels" -}}
helm.sh/chart: {{ include "firecrawl.chart" . }}
{{ include "worker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector worker labels
*/}}
{{- define "worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "firecrawl.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
nuq-worker labels
*/}}
{{- define "nuq-worker.labels" -}}
helm.sh/chart: {{ include "firecrawl.chart" . }}
{{ include "nuq-worker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector nuq-worker labels
*/}}
{{- define "nuq-worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "firecrawl.name" . }}-nuq-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "firecrawl.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "firecrawl.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
