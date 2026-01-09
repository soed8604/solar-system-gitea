{{/*
Expand the name of the chart.
*/}}
{{- define "solar-system.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "solar-system.fullname" -}}
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
{{- define "solar-system.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "solar-system.labels" -}}
helm.sh/chart: {{ include "solar-system.chart" . }}
{{ include "solar-system.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.environment }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "solar-system.selectorLabels" -}}
app.kubernetes.io/name: {{ include "solar-system.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Values.app.name }}
{{- end }}

{{/*
MongoDB labels
*/}}
{{- define "solar-system.mongodb.labels" -}}
helm.sh/chart: {{ include "solar-system.chart" . }}
{{ include "solar-system.mongodb.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.environment }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
MongoDB selector labels
*/}}
{{- define "solar-system.mongodb.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.mongodb.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Values.mongodb.name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "solar-system.annotations" -}}
{{- with .Values.commonAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}
