# ocp-dog-deployments

Repositorio declarativo para desplegar los microservicios `ocp-dog-frontend`, `ocp-dog-frontend-api` y `ocp-dog-backend-api` junto a su base de datos en OpenShift mediante Helm y GitHub Actions.

## Requisitos previos
- Acceso a un clúster de OpenShift 4.x con permisos para crear proyectos/espacios de nombres.
- Token de servicio con alcance al proyecto objetivo almacenado en el secret `OPENSHIFT_TOKEN`.
- Helm 3 y oc/kubectl instalados para despliegues manuales.

## Estructura del repositorio
```
├── charts/
│   ├── ocp-dog/
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── _helpers.tpl
│   │       ├── frontend-*.yaml
│   │       ├── backend-*.yaml
│   │       ├── database-*.yaml
│   │       ├── configmap.yaml / secrets.yaml
│   │       ├── network-policies.yaml
│   │       └── pvc.yaml
│   └── README.md
├── .github/workflows/deploy.yml
└── README.md
```
Cada manifest se genera desde Helm, garantizando que el despliegue completo (Deployments, Services, Route, ConfigMaps, Secrets, PVC y NetworkPolicies) se describa al 100 % en YAML.

## Variables de entorno y values
Actualiza `charts/ocp-dog/values.yaml` con tus rutas reales de Docker Hub y parámetros de entorno (por defecto se usan las imágenes publicadas en `docker.io/guscontre1` con tags fijos):
```yaml
images:
  frontend:
    repository: docker.io/guscontre1/ocp-dog-frontend
    tag: "1"
  frontendApi:
    repository: docker.io/guscontre1/ocp-dog-frontend-api
    tag: "2"
  backendApi:
    repository: docker.io/guscontre1/ocp-dog-backend-api
    tag: "6"
```
Cuando publiques nuevas versiones, cambia el tag correspondiente antes de ejecutar el despliegue. El campo `route.host` ya apunta a `ocp-dog-frontend.apps.rm1.0a51.p1.openshiftapps.com`; modifícalo si el dominio de tu proyecto en OpenShift es diferente. También puedes ajustar credenciales de base de datos, StorageClass o réplicas desde el mismo archivo.
El namespace por defecto definido en `values.yaml` y en el workflow es `guscontre-dev`; cambia ese valor si despliegas en otro proyecto.

## Despliegue manual
1. Inicia sesión en OpenShift:
   ```bash
   oc login https://api.rm1.0a51.p1.openshiftapps.com:6443 --token=$OPENSHIFT_TOKEN
   oc project guscontre-dev
   ```
2. Ejecuta Helm apuntando al chart:
   ```bash
   helm upgrade --install ocp-dog ./charts/ocp-dog -f charts/ocp-dog/values.yaml
   ```
3. Verifica recursos:
   ```bash
   oc get pods,svc,route,networkpolicy -l app=ocp-dog
   ```

## Despliegue automático (CI/CD)
El workflow `.github/workflows/deploy.yml` se activa en pushes a `main` o vía `workflow_dispatch` manual. Las etapas son:
1. Checkout del repositorio.
2. Instalación de `oc` y Helm.
3. Login en OpenShift usando `redhat-actions/oc-login` contra `https://api.rm1.0a51.p1.openshiftapps.com:6443` (ajusta la URL en el workflow si despliegas en otro clúster).
4. Ejecución de `helm upgrade --install ocp-dog ./charts/ocp-dog -f charts/ocp-dog/values.yaml`.

## Flujo de comunicación
El gráfico lógico del flujo (frontend → frontend-api → backend-api → database) queda respaldado por:
- Variables del `ConfigMap` que inyectan las URLs internas (`FRONTEND_API_URL`, `BACKEND_API_URL`).
- `NetworkPolicies` que solo permiten el tráfico requerido (frontend → frontend-api → backend-api → database) y bloquean cualquier otro flujo intra-namespace o externo.
- Probes HTTP `/healthz` en cada pod para asegurar observabilidad.

Con esto puedes versionar despliegues, reproducir entornos y automatizar cambios sin ejecutar comandos `oc` manuales fuera de Helm o GitHub Actions.
