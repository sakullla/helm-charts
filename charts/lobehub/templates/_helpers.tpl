{{/*
Expand the name of the chart.
*/}}
{{- define "lobehub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lobehub.fullname" -}}
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
{{- define "lobehub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lobehub.labels" -}}
helm.sh/chart: {{ include "lobehub.chart" . }}
{{ include "lobehub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lobehub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lobehub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lobehub.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lobehub.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Expand the embedded ParadeDB name.
*/}}
{{- define "lobehub.paradedbName" -}}
{{- default "paradedb" .Values.paradedb.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified ParadeDB name.
*/}}
{{- define "lobehub.paradedbFullname" -}}
{{- if .Values.paradedb.fullnameOverride }}
{{- .Values.paradedb.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "paradedb" .Values.paradedb.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create ParadeDB chart name and version as used by chart label.
*/}}
{{- define "lobehub.paradedbChart" -}}
{{- printf "%s-%s" "paradedb" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common ParadeDB labels.
*/}}
{{- define "lobehub.paradedbLabels" -}}
helm.sh/chart: {{ include "lobehub.paradedbChart" . }}
{{ include "lobehub.paradedbSelectorLabels" . }}
app.kubernetes.io/version: {{ .Values.paradedb.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
ParadeDB selector labels.
*/}}
{{- define "lobehub.paradedbSelectorLabels" -}}
app.kubernetes.io/name: {{ include "lobehub.paradedbName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Searxng subchart fullname.
*/}}
{{- define "lobehub.searxngFullname" -}}
{{- if .Values.searxng.fullnameOverride }}
{{- .Values.searxng.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "searxng" .Values.searxng.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Auto-generated DATABASE_URL for embedded ParadeDB.
*/}}
{{- define "lobehub.paradedbDatabaseUrl" -}}
{{- printf "postgres://%s:%s@%s:%v/%s" (.Values.paradedb.auth.username | urlquery) (.Values.paradedb.auth.password | urlquery) (include "lobehub.paradedbFullname" .) .Values.paradedb.service.port (.Values.paradedb.auth.database | urlquery) -}}
{{- end }}

{{/*
Auto-derived APP_URL.
*/}}
{{- define "lobehub.appUrl" -}}
{{- if .Values.app.url }}
{{- .Values.app.url -}}
{{- else if and .Values.httpRoute.enabled .Values.httpRoute.hostnames }}
{{- printf "https://%s" (first .Values.httpRoute.hostnames) -}}
{{- else if and .Values.ingress.enabled .Values.ingress.hosts }}
{{- printf "http%s://%s" (ternary "s" "" (gt (len .Values.ingress.tls) 0)) ((first .Values.ingress.hosts).host) -}}
{{- end }}
{{- end }}

{{/*
Auto-generated SearXNG base URL.
*/}}
{{- define "lobehub.searxngUrl" -}}
{{- printf "http://%s:%v" (include "lobehub.searxngFullname" .) .Values.searxng.service.port -}}
{{- end }}
