# Preview Environments - Quick Start

Guía rápida para implementar preview environments en tu repositorio.

## 🎯 En 5 Minutos

### 1. Copia los archivos necesarios

```bash
# Desde este repositorio, copia a tu proyecto:
cp -r helm/ tu-proyecto/
cp -r .github/workflows/ tu-proyecto/
```

### 2. Personaliza la configuración

Edita `helm/values.yaml`:

```yaml
app:
  name: tu-aplicacion  # ← Cambia esto

image:
  repository: ghcr.io/jeloulatam/tu-aplicacion  # ← Y esto
  tag: "latest"

service:
  port: 8080  # ← Puerto de tu app
```

Edita `helm/values-preview.yaml`:

```yaml
ingress:
  hosts:
    - host: "pr-{{ .Values.prNumber }}.preview.jelou.dev"  # ← Tu dominio
```

### 3. Configura GitHub Secrets

```bash
# En tu máquina con kubectl configurado:
cat ~/.kube/config | base64

# Copia el output y ve a:
# GitHub → Settings → Secrets → Actions → New secret
# Nombre: KUBECONFIG
# Valor: <pega el output de arriba>
```

### 4. Configura permisos de GitHub Actions

Settings → Actions → General → Workflow permissions:
- ✅ Read and write permissions
- ✅ Allow GitHub Actions to create and approve pull requests

### 5. Crea un PR de prueba

¡Listo! GitHub Actions automáticamente:
- Construirá tu imagen Docker
- La desplegará en Kubernetes
- Comentará en el PR con la URL del preview

## 🎨 Personalizar según tu stack

### Node.js / Express

Ya está configurado. Solo ajusta el puerto en `values.yaml`.

### Python / Flask / Django

Actualiza `Dockerfile` y `values.yaml`:

```yaml
service:
  port: 8000  # Puerto típico de Django/Flask
```

### React / Next.js / Frontend

```yaml
service:
  port: 3000  # Puerto típico de Next.js

# Si es solo frontend, desactiva MongoDB:
mongodb:
  enabled: false
```

### Go / Gin / Echo

```yaml
service:
  port: 8080  # Puerto típico de Go

mongodb:
  enabled: false  # Si no usas MongoDB
```

## 🗄️ Base de Datos

### Ya tienes MongoDB

Perfecto, ya está configurado.

### Usas PostgreSQL

Edita `helm/values.yaml`:

```yaml
mongodb:
  enabled: false  # Desactiva MongoDB

postgresql:
  enabled: true
  auth:
    username: postgres
    password: postgres123
    database: myapp
```

Y agrega el template `helm/templates/postgresql.yaml` (puedes usar el de MongoDB como base).

### Usas MySQL

Similar a PostgreSQL, reemplaza el deployment de MongoDB.

### No usas base de datos

```yaml
mongodb:
  enabled: false
```

## 🌐 Variables de Entorno

Agrega en `helm/templates/deployment.yaml` bajo `env:`:

```yaml
- name: API_URL
  value: "https://api.jelou.dev"
- name: NODE_ENV
  value: {{ .Values.environment | quote }}
- name: DATABASE_URL
  value: {{ .Values.databaseUrl | quote }}
```

Y en `values-preview.yaml`:

```yaml
databaseUrl: "postgresql://user:pass@db:5432/preview"
```

## 🔒 Secrets

### Opción 1: Secrets de Kubernetes (Recomendado)

Crea el secret:

```bash
kubectl create secret generic app-secrets \
  --from-literal=api-key=tu-api-key \
  --from-literal=jwt-secret=tu-jwt-secret \
  -n solar-system-pr-123
```

Úsalo en `deployment.yaml`:

```yaml
env:
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: api-key
```

### Opción 2: GitHub Secrets

En el workflow `pr-deploy.yml`:

```yaml
- name: Deploy with Helm
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    helm upgrade --install ... \
      --set env.apiKey=$API_KEY
```

## 📊 Recursos de Kubernetes

Ajusta según tus necesidades en `values-preview.yaml`:

### App pequeña
```yaml
resources:
  limits:
    cpu: 250m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

### App mediana (default)
```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### App grande
```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi
```

## 🚨 Troubleshooting Rápido

### El workflow falla

1. Revisa los logs en GitHub Actions
2. Verifica que los secrets estén configurados
3. Verifica permisos de GitHub Actions

### El pod no inicia

```bash
# Ver logs
kubectl logs -n solar-system-pr-123 deployment/solar-system

# Ver eventos
kubectl get events -n solar-system-pr-123 --sort-by='.lastTimestamp'
```

### La URL no funciona

1. Verifica que el Ingress Controller esté instalado
2. Verifica el DNS: `nslookup pr-123.preview.jelou.dev`
3. Espera unos minutos para que el DNS se propague

### Namespace no se elimina

```bash
# Forzar eliminación
kubectl delete namespace solar-system-pr-123 --grace-period=0 --force
```

## 📚 Siguiente Paso

Lee la documentación completa en [PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md) para:
- Configuración avanzada
- Troubleshooting detallado
- Mejores prácticas
- Monitoreo y métricas

## ❓ Ayuda

- Canal de Slack: `#devops`
- Email: devops@jelou.ai
- Documentación completa: [PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md)

---

¡Feliz deployment! 🚀
