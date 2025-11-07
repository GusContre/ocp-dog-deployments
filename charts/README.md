# Charts

Este directorio contiene los charts de Helm utilizados para desplegar la plataforma ocp-dog en OpenShift. El chart principal es `ocp-dog` y agrupa los tres microservicios (frontend, frontend-api y backend-api) junto con la base de datos y todos los objetos auxiliares (Routes, ConfigMaps, Secrets, PVCs y NetworkPolicies).

Cada componente lee sus valores desde `values.yaml`, por lo que basta con actualizar imágenes, recursos o dominios allí para propagar los cambios a todos los manifiestos renderizados por Helm.
