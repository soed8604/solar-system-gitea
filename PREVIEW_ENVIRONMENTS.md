# Preview Environments - Guía Completa

Esta guía explica cómo funcionan los preview environments automáticos para PRs en JelouLatam.

## 📋 Tabla de Contenidos

- [¿Qué son los Preview Environments?](#qué-son-los-preview-environments)
- [Arquitectura](#arquitectura)
- [Requisitos Previos](#requisitos-previos)
- [Configuración Inicial](#configuración-inicial)
- [Uso](#uso)
- [Configuración Avanzada](#configuración-avanzada)
- [Troubleshooting](#troubleshooting)

## 🎯 ¿Qué son los Preview Environments?

Los **Preview Environments** son entornos temporales y aislados que se crean automáticamente para cada Pull Request. Permiten:

- ✅ Probar cambios en un entorno real antes de hacer merge
- ✅ Compartir una URL única con el equipo para revisión
- ✅ Ejecutar tests de integración en un ambiente aislado
- ✅ Validar cambios sin afectar otros entornos
- ✅ Limpieza automática al cerrar el PR

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Pull Request                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions Workflow (pr-deploy)             │
│                                                               │
│  1. Build Docker image                                       │
│  2. Push to Container Registry (GHCR)                        │
│  3. Create namespace: solar-system-pr-{number}               │
│  4. Deploy with Helm                                         │
│  5. Comment PR with preview URL                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                          │
│                                                               │
│  Namespace: solar-system-pr-123                              │
│  ├── Deployment: solar-system                                │
│  ├── Service: solar-system                                   │
│  ├── Ingress: pr-123.preview.jelou.dev                       │
│  ├── MongoDB Deployment                                      │
│  ├── MongoDB Service                                         │
│  └── ConfigMap: mongo-init                                   │
└─────────────────────────────────────────────────────────────┘
```

Cuando el PR se cierra:

```
┌─────────────────────────────────────────────────────────────┐
│           GitHub Actions Workflow (pr-cleanup)               │
│                                                               │
│  1. Uninstall Helm release                                   │
│  2. Delete namespace                                         │
│  3. Comment PR with cleanup status                           │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Requisitos Previos

### 1. Infraestructura de Kubernetes

Necesitas un cluster de Kubernetes con:

- **Ingress Controller** (NGINX, Traefik, etc.)
- **Cert-Manager** (opcional, para SSL/TLS automático)
- **DNS** configurado con wildcard: `*.preview.jelou.dev`

### 2. Repositorio de Imágenes

- GitHub Container Registry (GHCR) - Recomendado y gratuito
- O cualquier otro registry (Docker Hub, ECR, GCR, etc.)

### 3. Secrets de GitHub

Configura los siguientes secrets en tu repositorio:

| Secret | Descripción | Cómo obtenerlo |
|--------|-------------|----------------|
| `KUBECONFIG` | Configuración de kubectl en base64 | `cat ~/.kube/config \| base64` |

### 4. Permisos de GitHub Actions

Asegúrate de que GitHub Actions tenga permisos para:
- Leer el código (`contents: read`)
- Escribir paquetes (`packages: write`)
- Comentar en PRs (`pull-requests: write`)

## 🚀 Configuración Inicial

### Paso 1: Copiar Estructura de Archivos

Copia los siguientes directorios y archivos a tu repositorio:

```bash
# Helm chart
helm/
├── Chart.yaml
├── values.yaml
├── values-preview.yaml
├── .helmignore
└── templates/
    ├── _helpers.tpl
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── mongodb-configmap.yaml
    ├── mongodb-deployment.yaml
    ├── mongodb-service.yaml
    └── mongodb-pvc.yaml

# GitHub Actions workflows
.github/
└── workflows/
    ├── pr-deploy.yml
    └── pr-cleanup.yml

# Dockerfile (si no existe)
Dockerfile
```

### Paso 2: Adaptar Helm Chart

Edita `helm/values.yaml` y `helm/values-preview.yaml` según tu aplicación:

#### Configuración Básica (`values.yaml`)

```yaml
app:
  name: tu-aplicacion  # Cambiar nombre
  replicaCount: 1

image:
  repository: ghcr.io/jelou-latam/tu-aplicacion  # Tu imagen
  tag: "latest"

service:
  port: 3000  # Puerto de tu aplicación

# Si no usas MongoDB, desactívalo
mongodb:
  enabled: false
```

#### Preview Environment (`values-preview.yaml`)

```yaml
ingress:
  hosts:
    - host: "pr-{{ .Values.prNumber }}.preview.jelou.dev"
      # Cambiar dominio según tu configuración
```

### Paso 3: Configurar GitHub Secrets

1. Ve a tu repositorio → Settings → Secrets and variables → Actions
2. Agrega el secret `KUBECONFIG`:

```bash
# En tu máquina local con kubectl configurado
cat ~/.kube/config | base64 | pbcopy  # macOS
cat ~/.kube/config | base64 | xclip   # Linux
```

3. Pega el valor en GitHub

### Paso 4: Configurar Permisos de GitHub Actions

1. Ve a Settings → Actions → General
2. En "Workflow permissions", selecciona:
   - ✅ Read and write permissions
   - ✅ Allow GitHub Actions to create and approve pull requests

### Paso 5: Configurar DNS

Configura un registro DNS wildcard:

```
*.preview.jelou.dev  →  A  →  [IP del Load Balancer de tu Ingress]
```

### Paso 6: Instalar Cert-Manager (Opcional)

Para SSL/TLS automático:

```bash
# Instalar cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Crear ClusterIssuer para Let's Encrypt
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: devops@jelou.ai
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: devops@jelou.ai
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

## 💻 Uso

### Crear un Preview Environment

1. Crea un Pull Request contra la rama `main`
2. GitHub Actions automáticamente:
   - Construye la imagen Docker
   - La sube a GHCR
   - Crea un namespace `solar-system-pr-{número}`
   - Despliega la aplicación con Helm
   - Comenta en el PR con la URL del preview

### Actualizar un Preview Environment

Simplemente haz push de nuevos commits al PR. El workflow se ejecutará automáticamente.

### Eliminar un Preview Environment

Cierra o mergea el PR. El workflow de cleanup eliminará automáticamente todos los recursos.

## ⚙️ Configuración Avanzada

### Personalizar Recursos

Edita `helm/values-preview.yaml`:

```yaml
resources:
  limits:
    cpu: 500m      # Ajustar según necesidades
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Agregar Variables de Entorno

En `helm/templates/deployment.yaml`:

```yaml
env:
  - name: API_URL
    value: "https://api.jelou.dev"
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: database-credentials
        key: url
```

### Usar Secrets de Kubernetes

```bash
# Crear secret en cada namespace de preview
kubectl create secret generic database-credentials \
  --from-literal=url=postgresql://... \
  -n solar-system-pr-123
```

O automatízalo en el workflow:

```yaml
- name: Create secrets
  run: |
    kubectl create secret generic database-credentials \
      --from-literal=url=${{ secrets.DATABASE_URL }} \
      -n solar-system-pr-${{ github.event.pull_request.number }} \
      --dry-run=client -o yaml | kubectl apply -f -
```

### Cambiar Registry

Para usar Docker Hub en lugar de GHCR:

```yaml
# En pr-deploy.yml
env:
  REGISTRY: docker.io
  IMAGE_NAME: jelou/tu-aplicacion

# Y agrega secrets
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

### Agregar Tests Pre-Deploy

En `pr-deploy.yml`, antes del deploy:

```yaml
- name: Run tests
  run: |
    npm install
    npm test

- name: Run linter
  run: |
    npm run lint
```

### Notificaciones a Slack

Agrega al final de `pr-deploy.yml`:

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: |
      Preview deployed: ${{ steps.preview-url.outputs.url }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## 🔧 Troubleshooting

### El workflow falla en "Build and push Docker image"

**Síntomas:**
```
Error: failed to solve: failed to push: permission denied
```

**Solución:**
1. Verifica que el paquete sea público o que GitHub Actions tenga permisos
2. Ve a Package settings → Actions access → Allow write access

### El pod no inicia - ImagePullBackOff

**Síntomas:**
```
kubectl get pods -n solar-system-pr-123
NAME                            READY   STATUS             RESTARTS   AGE
solar-system-xxx                0/1     ImagePullBackOff   0          2m
```

**Solución:**
1. Verifica que la imagen exista:
```bash
docker pull ghcr.io/jeloulatam/solar-system:pr-123-abc123
```

2. Si es un registry privado, crea un imagePullSecret:
```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=$GITHUB_ACTOR \
  --docker-password=$GITHUB_TOKEN \
  -n solar-system-pr-123
```

### Ingress no funciona - 404 Not Found

**Síntomas:**
- La URL del preview devuelve 404
- `kubectl get ingress` muestra ADDRESS vacío

**Solución:**
1. Verifica que el Ingress Controller esté instalado:
```bash
kubectl get pods -n ingress-nginx
```

2. Verifica el ingress:
```bash
kubectl describe ingress -n solar-system-pr-123
```

3. Verifica que el DNS esté configurado:
```bash
nslookup pr-123.preview.jelou.dev
```

### MongoDB no inicia

**Síntomas:**
- Error de conexión a MongoDB
- Pod de MongoDB en CrashLoopBackOff

**Solución:**
1. Verifica logs:
```bash
kubectl logs -n solar-system-pr-123 deployment/mongodb
```

2. Aumenta recursos si es necesario en `values-preview.yaml`:
```yaml
mongodb:
  resources:
    requests:
      memory: 512Mi
```

### Namespace no se elimina

**Síntomas:**
- Namespace queda en estado "Terminating"

**Solución:**
```bash
# Forzar eliminación
kubectl get namespace solar-system-pr-123 -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/solar-system-pr-123/finalize -f -
```

### Certificado SSL no se genera

**Síntomas:**
- HTTPS no funciona
- Cert-manager no crea el certificado

**Solución:**
1. Verifica cert-manager:
```bash
kubectl get pods -n cert-manager
```

2. Verifica el certificado:
```bash
kubectl get certificate -n solar-system-pr-123
kubectl describe certificate -n solar-system-pr-123
```

3. Verifica el ClusterIssuer:
```bash
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-staging
```

## 📊 Monitoreo y Métricas

### Ver todos los preview environments activos

```bash
kubectl get namespaces -l environment=preview
```

### Ver recursos de un preview específico

```bash
NAMESPACE="solar-system-pr-123"
kubectl get all -n $NAMESPACE
kubectl top pods -n $NAMESPACE  # Uso de recursos
```

### Listar todos los releases de Helm

```bash
helm list -A | grep preview
```

## 🧹 Limpieza Manual

Si necesitas limpiar manualmente un preview environment:

```bash
PR_NUMBER=123
NAMESPACE="solar-system-pr-${PR_NUMBER}"
RELEASE_NAME="solar-system-pr-${PR_NUMBER}"

# Eliminar release de Helm
helm uninstall $RELEASE_NAME -n $NAMESPACE

# Eliminar namespace
kubectl delete namespace $NAMESPACE
```

## 📝 Checklist de Implementación

Usa este checklist al implementar en un nuevo repositorio:

- [ ] Copiar estructura de archivos (helm/, .github/)
- [ ] Adaptar `helm/values.yaml` con configuración de tu app
- [ ] Adaptar `helm/values-preview.yaml` con tu dominio
- [ ] Configurar secret `KUBECONFIG` en GitHub
- [ ] Configurar permisos de GitHub Actions
- [ ] Configurar DNS wildcard
- [ ] (Opcional) Instalar cert-manager
- [ ] (Opcional) Configurar ClusterIssuers
- [ ] Probar con un PR de prueba
- [ ] Verificar que el preview se despliega correctamente
- [ ] Verificar que el cleanup funciona al cerrar el PR
- [ ] Documentar URLs y configuración específica del proyecto

## 🎓 Recursos Adicionales

- [Documentación de Helm](https://helm.sh/docs/)
- [GitHub Actions para Kubernetes](https://github.com/marketplace?type=actions&query=kubernetes)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## 🤝 Soporte

Si tienes problemas o preguntas:

1. Revisa esta documentación y la sección de Troubleshooting
2. Verifica los logs de GitHub Actions
3. Contacta al equipo de DevOps en el canal de Slack

---

**Mantenido por:** Equipo DevOps JelouLatam
**Última actualización:** 2026-01-05
