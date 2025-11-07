{{- define "ocp-dog.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ocp-dog.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "ocp-dog.labels" -}}
app: {{ .Values.app.name }}
chart: {{ .Chart.Name }}
release: {{ .Release.Name }}
heritage: Helm
{{- end -}}

{{- define "ocp-dog.image" -}}
{{- $repository := required "images.*.repository es obligatorio" .repository -}}
{{- $tag := default "latest" .tag -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
