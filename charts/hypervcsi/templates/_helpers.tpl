{{/*
Expand the name of the chart.
*/}}
{{- define "hypervcsi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hypervcsi.fullname" -}}
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
{{- define "hypervcsi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hypervcsi.labels" -}}
helm.sh/chart: {{ include "hypervcsi.chart" . }}
{{ include "hypervcsi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hypervcsi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hypervcsi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hypervcsi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hypervcsi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
License file mount, shared by the controller, the node driver and the WebApi.
Set global.license.existingSecret to a Secret holding the signed license (key: global.license.secretKey,
default "license.lic"); it is mounted read-only at /etc/hypervcsi/license/license.lic, the default
Licensing:LicenseFilePath. Nothing is mounted when existingSecret is empty.
*/}}
{{- define "hypervcsi.licenseVolumeMount" -}}
{{- if (dig "license" "existingSecret" "" .Values.global) }}
- name: license
  mountPath: /etc/hypervcsi/license
  readOnly: true
{{- end }}
{{- end }}

{{- define "hypervcsi.licenseVolume" -}}
{{- with (dig "license" "existingSecret" "" .Values.global) }}
- name: license
  secret:
    secretName: {{ . }}
    items:
      - key: {{ dig "license" "secretKey" "license.lic" $.Values.global }}
        path: license.lic
{{- end }}
{{- end }}

