{{/*
Expand the name of the chart.
*/}}
{{- define "linkerx-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "linkerx-agent.fullname" -}}
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
{{- define "linkerx-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "linkerx-agent.labels" -}}
helm.sh/chart: {{ include "linkerx-agent.chart" . }}
{{ include "linkerx-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (backend)
*/}}
{{- define "linkerx-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "linkerx-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "linkerx-agent.frontendLabels" -}}
helm.sh/chart: {{ include "linkerx-agent.chart" . }}
{{ include "linkerx-agent.frontendSelectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "linkerx-agent.frontendSelectorLabels" -}}
app.kubernetes.io/name: {{ include "linkerx-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "linkerx-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "linkerx-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend fullname
*/}}
{{- define "linkerx-agent.backendFullname" -}}
{{- printf "%s-backend" (include "linkerx-agent.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Frontend fullname
*/}}
{{- define "linkerx-agent.frontendFullname" -}}
{{- printf "%s-frontend" (include "linkerx-agent.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate a random 64-char hex string for secrets.
*/}}
{{- define "linkerx-agent.randHex" -}}
{{- randAlphaNum 64 | lower | trunc 64 }}
{{- end }}
