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
Expand the embedded browserless name.
*/}}
{{- define "browserless-chromium.name" -}}
{{- $browserless := index .Values "browserless-chromium" -}}
{{- default "browserless-chromium" $browserless.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified browserless name.
*/}}
{{- define "browserless-chromium.fullname" -}}
{{- $browserless := index .Values "browserless-chromium" -}}
{{- if $browserless.fullnameOverride }}
{{- $browserless.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "browserless-chromium" $browserless.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create browserless chart name and version as used by chart label.
*/}}
{{- define "browserless-chromium.chart" -}}
{{- printf "%s-%s" "browserless-chromium" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Default browserless app version.
*/}}
{{- define "browserless-chromium.appVersion" -}}
{{- $browserless := index .Values "browserless-chromium" -}}
{{- $browserless.image.tag -}}
{{- end }}

{{/*
Common browserless labels.
*/}}
{{- define "browserless-chromium.labels" -}}
helm.sh/chart: {{ include "browserless-chromium.chart" . }}
{{ include "browserless-chromium.selectorLabels" . }}
app.kubernetes.io/version: {{ include "browserless-chromium.appVersion" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Browserless selector labels.
*/}}
{{- define "browserless-chromium.selectorLabels" -}}
app.kubernetes.io/name: {{ include "browserless-chromium.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
