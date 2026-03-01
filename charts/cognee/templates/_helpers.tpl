{{/* Expand the name of the chart. */}}
{{- define "cognee.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name. */}}
{{- define "cognee.fullname" -}}
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

{{/* Create chart name and version as used by the chart label. */}}
{{- define "cognee.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels for API resources. */}}
{{- define "cognee.labels" -}}
helm.sh/chart: {{ include "cognee.chart" . }}
{{ include "cognee.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels for API resources. */}}
{{- define "cognee.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cognee.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Create the name of the service account to use. */}}
{{- define "cognee.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cognee.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Component names. */}}
{{- define "cognee.postgresFullname" -}}
{{- printf "%s-postgres" (include "cognee.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "cognee.chromadbFullname" -}}
{{- printf "%s-chromadb" (include "cognee.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- define "cognee.neo4jFullname" -}}
{{- printf "%s-neo4j" (include "cognee.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Component selector labels. */}}
{{- define "cognee.postgresSelectorLabels" -}}
app.kubernetes.io/name: {{ include "cognee.name" . }}-postgres
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "cognee.chromadbSelectorLabels" -}}
app.kubernetes.io/name: {{ include "cognee.name" . }}-chromadb
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "cognee.neo4jSelectorLabels" -}}
app.kubernetes.io/name: {{ include "cognee.name" . }}-neo4j
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Component common labels. */}}
{{- define "cognee.postgresLabels" -}}
helm.sh/chart: {{ include "cognee.chart" . }}
{{ include "cognee.postgresSelectorLabels" . }}
app.kubernetes.io/component: postgres
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "cognee.chromadbLabels" -}}
helm.sh/chart: {{ include "cognee.chart" . }}
{{ include "cognee.chromadbSelectorLabels" . }}
app.kubernetes.io/component: chromadb
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
{{- define "cognee.neo4jLabels" -}}
helm.sh/chart: {{ include "cognee.chart" . }}
{{ include "cognee.neo4jSelectorLabels" . }}
app.kubernetes.io/component: neo4j
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
