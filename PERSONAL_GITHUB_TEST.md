# Prueba en GitHub Personal - Guía Paso a Paso

Esta guía te ayudará a probar los preview environments en tu cuenta personal de GitHub antes de implementarlo en la empresa.

## 🎯 Objetivo

Validar que todo funciona correctamente en un entorno de prueba antes de llevarlo a producción en JelouLatam.

## 📋 Pre-requisitos

Antes de empezar, necesitas:

- ✅ Cuenta personal de GitHub
- ✅ Cluster de Kubernetes (puede ser local con minikube/k3d/kind)
- ✅ kubectl configurado y funcionando
- ✅ Helm instalado
- ✅ Docker instalado

## 🔧 Opción 1: Prueba Local (Sin GitHub Actions)

Si no tienes un cluster en la nube, puedes probar localmente primero.

### Paso 1: Cluster Local con Minikube

```bash
# Instalar minikube (si no lo tienes)
# macOS
brew install minikube

# Iniciar cluster
minikube start --cpus=2 --memory=4096

# Habilitar ingress
minikube addons enable ingress

# Verificar
kubectl get pods -n ingress-nginx
```

### Paso 2: Build Local de la Imagen

```bash
# Configurar Docker para usar el daemon de minikube
eval $(minikube docker-env)

# Build de la imagen
docker build -t solar-system-app:test .

# Verificar que la imagen existe
docker images | grep solar-system-app
```

### Paso 3: Deploy con Helm

```bash
# Crear namespace de prueba
kubectl create namespace solar-system-test

# Deploy con Helm
helm install solar-system-test ./helm \
  --namespace solar-system-test \
  --set image.repository=solar-system-app \
  --set image.tag=test \
  --set image.pullPolicy=Never \
  --set namespace=solar-system-test \
  --set ingress.enabled=false

# Verificar que los pods están corriendo
kubectl get pods -n solar-system-test

# Esperar a que estén ready
kubectl wait --for=condition=ready pod -l app=solar-system -n solar-system-test --timeout=300s
```

### Paso 4: Probar la Aplicación

```bash
# Port-forward para acceder
kubectl port-forward -n solar-system-test svc/solar-system-test 3000:3000

# En otro terminal o abre en el navegador:
# http://localhost:3000
```

### Paso 5: Limpiar

```bash
# Eliminar release
helm uninstall solar-system-test -n solar-system-test

# Eliminar namespace
kubectl delete namespace solar-system-test
```

## ☁️ Opción 2: Prueba Completa con GitHub Actions

Para probar el flujo completo con GitHub Actions.

### Paso 1: Fork/Crear Repositorio Personal

```bash
# Si aún no lo has hecho, push a tu GitHub personal
git remote add personal https://github.com/TU-USUARIO/solar-system-gitea.git
git push personal main
```

### Paso 2: Configurar para Prueba Personal

Crea un archivo temporal con tus valores personales:

```bash
# Crear archivo de configuración personal
cat > helm/values-personal-test.yaml <<EOF
# Configuración para prueba personal
environment: personal-test

# Tu namespace personal
namespace: solar-system-personal

app:
  name: solar-system
  replicaCount: 1

image:
  repository: ghcr.io/TU-USUARIO-GITHUB/solar-system-gitea
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 3000
  targetPort: 3000

# Ingress deshabilitado por ahora (habilitarlo después con tu dominio)
ingress:
  enabled: false

# Recursos mínimos para prueba
resources:
  limits:
    cpu: 250m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 64Mi

mongodb:
  enabled: true
  resources:
    limits:
      cpu: 250m
      memory: 256Mi
    requests:
      cpu: 50m
      memory: 128Mi
EOF
```

### Paso 3: Actualizar Workflows para GitHub Personal

Edita `.github/workflows/pr-deploy.yml`:

```yaml
# Línea 6-7, actualizar:
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}  # Esto ya usa tu usuario automáticamente

# Línea 51, actualizar el namespace:
- name: Create namespace
  run: |
    NAMESPACE="solar-system-pr-${{ github.event.pull_request.number }}"
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    kubectl label namespace $NAMESPACE environment=preview pr-number=${{ github.event.pull_request.number }} --overwrite

# Línea 62-70, actualizar para usar dominio personal o IP
- name: Deploy with Helm
  run: |
    NAMESPACE="solar-system-pr-${{ github.event.pull_request.number }}"
    IMAGE_TAG="pr-${{ github.event.pull_request.number }}-${GITHUB_SHA::7}"

    helm upgrade --install \
      solar-system-pr-${{ github.event.pull_request.number }} \
      ./helm \
      --namespace $NAMESPACE \
      --create-namespace \
      --values ./helm/values-preview.yaml \
      --set image.repository=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }} \
      --set image.tag=$IMAGE_TAG \
      --set namespace=$NAMESPACE \
      --set prNumber=${{ github.event.pull_request.number }} \
      --set ingress.enabled=false \
      --wait \
      --timeout 5m
```

### Paso 4: Configurar Secrets en GitHub Personal

1. Ve a tu repositorio personal en GitHub
2. Settings → Secrets and variables → Actions → New repository secret

**Secret 1: KUBECONFIG**

```bash
# Si usas minikube:
kubectl config view --flatten --minify | base64

# Si usas un cluster en la nube:
cat ~/.kube/config | base64
```

Copia el output y créalo como secret `KUBECONFIG`

### Paso 5: Habilitar GitHub Container Registry (GHCR)

1. Ve a tu perfil de GitHub → Settings (de tu usuario, no del repo)
2. Developer settings → Personal access tokens → Tokens (classic)
3. Generate new token (classic) con permisos:
   - ✅ `write:packages`
   - ✅ `read:packages`
   - ✅ `delete:packages`
4. Copia el token (lo necesitarás después)

**Nota:** GitHub Actions automáticamente usará `GITHUB_TOKEN` que ya tiene permisos para GHCR.

### Paso 6: Configurar Permisos del Workflow

En tu repo personal:

1. Settings → Actions → General
2. Workflow permissions:
   - ✅ Read and write permissions
   - ✅ Allow GitHub Actions to create and approve pull requests

### Paso 7: Hacer Push de los Cambios

```bash
# Asegúrate de que los workflows estén en el repo
git add .github/workflows/
git add helm/
git commit -m "chore: add preview environments for personal testing"
git push personal main
```

### Paso 8: Crear PR de Prueba

```bash
# Crear rama de prueba
git checkout -b test/preview-env-validation

# Hacer un cambio pequeño
echo "## Testing Preview Environments" >> README.md

# Commit y push
git add README.md
git commit -m "test: validate preview environment"
git push personal test/preview-env-validation
```

### Paso 9: Crear el Pull Request

1. Ve a tu repositorio en GitHub
2. Verás un banner "Compare & pull request"
3. Crea el PR
4. Ve a la pestaña "Actions" para ver el workflow ejecutándose

### Paso 10: Verificar el Deployment

```bash
# Reemplaza 1 con el número de tu PR
PR_NUMBER=1
NAMESPACE="solar-system-pr-${PR_NUMBER}"

# Ver todos los recursos
kubectl get all -n $NAMESPACE

# Ver logs de la aplicación
kubectl logs -n $NAMESPACE -l app=solar-system --tail=50 -f

# Port-forward para probar (si ingress está deshabilitado)
kubectl port-forward -n $NAMESPACE svc/solar-system-pr-${PR_NUMBER} 3000:3000

# Abre http://localhost:3000 en tu navegador
```

### Paso 11: Probar el Cleanup

1. Cierra el PR en GitHub
2. Ve a Actions y verifica que el workflow de cleanup se ejecuta
3. Verifica que el namespace se eliminó:

```bash
kubectl get namespace $NAMESPACE
# Debe mostrar "Error from server (NotFound)"
```

## 🌐 Opción 3: Con Dominio Personal (Opcional)

Si tienes un dominio personal y quieres probar el ingress completo:

### Paso 1: Configurar DNS

Agrega un registro A wildcard:

```
*.preview.tu-dominio.com  →  A  →  [IP-DE-TU-CLUSTER]
```

Para obtener la IP:

```bash
# Si usas minikube:
minikube ip

# Si usas cloud:
kubectl get svc -n ingress-nginx
# Buscar la EXTERNAL-IP
```

### Paso 2: Actualizar values-preview.yaml

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    # Sin cert-manager por ahora
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  hosts:
    - host: "pr-{{ .Values.prNumber }}.preview.tu-dominio.com"
      paths:
        - path: /
          pathType: Prefix
  # TLS deshabilitado por ahora
  tls: []
```

### Paso 3: Re-deploy y Probar

```bash
# El workflow automáticamente usará la nueva configuración
# Accede a: http://pr-1.preview.tu-dominio.com
```

## ✅ Checklist de Validación

Marca cada item al completarlo:

### Prueba Local
- [ ] Minikube iniciado correctamente
- [ ] Imagen Docker construida
- [ ] Helm chart desplegado sin errores
- [ ] Pods en estado Running y Ready
- [ ] Aplicación accesible via port-forward
- [ ] MongoDB funcionando correctamente
- [ ] Cleanup exitoso

### Prueba con GitHub Actions
- [ ] Repositorio creado/forked en GitHub personal
- [ ] Secret KUBECONFIG configurado
- [ ] Permisos de GitHub Actions configurados
- [ ] Workflow de deploy se ejecuta sin errores
- [ ] Namespace creado automáticamente
- [ ] Pods desplegados correctamente
- [ ] Comentario en PR con información (puede fallar si no hay ingress, es OK)
- [ ] Workflow de cleanup se ejecuta al cerrar PR
- [ ] Namespace eliminado correctamente

### Prueba con Ingress (Opcional)
- [ ] DNS configurado
- [ ] Ingress creado correctamente
- [ ] URL accesible desde navegador
- [ ] Aplicación funciona completamente

## 🐛 Troubleshooting Personal

### Error: "failed to push: permission denied"

**Solución:**
1. Verifica que el paquete sea público
2. Ve a tu paquete en GitHub
3. Package settings → Change visibility → Public

### Error: "unauthorized: unauthenticated"

**Solución:**
El GITHUB_TOKEN debe tener permisos. Verifica en Settings → Actions → General → Workflow permissions.

### Minikube: Ingress no funciona

**Solución:**
```bash
# Verificar que ingress está habilitado
minikube addons list | grep ingress

# Si no está habilitado:
minikube addons enable ingress

# Esperar a que el controller esté listo
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### Imagen no se encuentra en minikube

**Solución:**
```bash
# Asegúrate de usar el daemon de docker de minikube
eval $(minikube docker-env)

# Rebuild
docker build -t solar-system-app:test .

# Verificar
docker images | grep solar-system

# En el helm install, usa:
--set image.pullPolicy=Never
```

### Port-forward no funciona

**Solución:**
```bash
# Verifica que el pod esté corriendo
kubectl get pods -n $NAMESPACE

# Verifica el nombre del servicio
kubectl get svc -n $NAMESPACE

# Usa el nombre correcto del servicio
kubectl port-forward -n $NAMESPACE svc/NOMBRE-CORRECTO 3000:3000
```

## 📊 Diferencias: Personal vs Empresa

| Aspecto | GitHub Personal | GitHub Empresa |
|---------|----------------|----------------|
| Registry | `ghcr.io/tu-usuario` | `ghcr.io/jeloulatam` |
| Dominio | `preview.tu-dominio.com` | `preview.jelou.dev` |
| Cluster | Minikube/Local o personal | Cluster empresarial |
| Namespace | `solar-system-pr-X` | `solar-system-pr-X` |
| Recursos | Más limitados | Según políticas |
| Cert-Manager | Opcional | Recomendado |

## 🎓 Próximos Pasos

Después de validar en tu cuenta personal:

1. **Documenta aprendizajes:**
   - ¿Qué funcionó bien?
   - ¿Qué problemas encontraste?
   - ¿Qué ajustes hiciste?

2. **Prepara migración a empresa:**
   - Lista de cambios necesarios
   - Secrets requeridos
   - Configuración de DNS empresarial
   - Políticas de recursos

3. **Presenta a DevOps:**
   - Muestra la prueba funcionando
   - Comparte documentación
   - Discute implementación en repos empresariales

## 💡 Tips para la Prueba

1. **Empieza simple:** Primero prueba localmente con minikube
2. **Avanza gradual:** Luego prueba con GitHub Actions sin ingress
3. **Completa:** Finalmente agrega ingress si tienes dominio
4. **Documenta todo:** Toma notas de los problemas y soluciones
5. **Comparte:** Comparte tu experiencia con el equipo

## 📝 Notas

Crea un archivo `NOTAS_PRUEBA.md` con:

```markdown
# Notas de Prueba - Preview Environments

## Fecha: [FECHA]

### Entorno
- SO: [macOS/Linux/Windows]
- Kubernetes: [minikube/k3d/cloud]
- Versión de Helm: [versión]
- Versión de kubectl: [versión]

### Problemas Encontrados
1. [Problema 1]
   - Solución: [...]

### Ajustes Realizados
1. [Ajuste 1]
   - Razón: [...]

### Tiempos
- Setup inicial: [X minutos]
- Primer deploy exitoso: [X minutos]
- Troubleshooting: [X minutos]

### Recomendaciones para Empresa
1. [Recomendación 1]
```

---

**¡Buena suerte con la prueba!** 🚀

Cualquier duda, consulta la documentación principal o abre un issue en el repo.
