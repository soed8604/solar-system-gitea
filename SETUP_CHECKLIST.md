# Setup Checklist - Preview Environments

Usa este checklist al configurar preview environments en un nuevo repositorio.

## 📋 Pre-requisitos de Infraestructura

- [ ] **Kubernetes Cluster** está disponible y accesible
- [ ] **Ingress Controller** (NGINX/Traefik) está instalado
  ```bash
  kubectl get pods -n ingress-nginx
  ```
- [ ] **Cert-Manager** está instalado (opcional, para SSL)
  ```bash
  kubectl get pods -n cert-manager
  ```
- [ ] **DNS Wildcard** está configurado (`*.preview.jelou.dev`)
  ```bash
  nslookup pr-test.preview.jelou.dev
  ```
- [ ] **Container Registry** está disponible (GHCR, Docker Hub, etc.)

## 📂 Archivos del Repositorio

### Helm Chart

- [ ] Copiar directorio `helm/` al repositorio
- [ ] Editar `helm/Chart.yaml`:
  - [ ] Actualizar `name`
  - [ ] Actualizar `description`
  - [ ] Actualizar `version`
  - [ ] Actualizar `appVersion`

- [ ] Editar `helm/values.yaml`:
  - [ ] Actualizar `app.name`
  - [ ] Actualizar `image.repository`
  - [ ] Actualizar `service.port` (puerto de tu app)
  - [ ] Configurar `mongodb.enabled` (true/false)
  - [ ] Ajustar `resources` según necesidades

- [ ] Editar `helm/values-preview.yaml`:
  - [ ] Actualizar `ingress.hosts[0].host` con tu dominio
  - [ ] Actualizar `ingress.tls[0].hosts[0]` con tu dominio
  - [ ] Ajustar `resources` para preview (opcional)

- [ ] Revisar templates en `helm/templates/`:
  - [ ] `deployment.yaml` tiene las env vars correctas
  - [ ] `service.yaml` expone los puertos correctos
  - [ ] `ingress.yaml` tiene las anotaciones correctas
  - [ ] Agregar/eliminar templates según necesidad (ej: PostgreSQL, Redis)

### GitHub Actions

- [ ] Copiar directorio `.github/workflows/` al repositorio
- [ ] Editar `.github/workflows/pr-deploy.yml`:
  - [ ] Actualizar `IMAGE_NAME` si es necesario
  - [ ] Actualizar referencias de namespace (`solar-system-pr-` → `tu-app-pr-`)
  - [ ] Actualizar path del helm chart si está en otro directorio
  - [ ] Agregar steps adicionales si necesario (tests, linting, etc.)

- [ ] Editar `.github/workflows/pr-cleanup.yml`:
  - [ ] Actualizar referencias de namespace
  - [ ] Actualizar nombre del release de Helm

### Dockerfile

- [ ] Verificar que `Dockerfile` existe
- [ ] Verificar que está optimizado (multi-stage build, etc.)
- [ ] Verificar que expone el puerto correcto
- [ ] Verificar que las env vars están configuradas
- [ ] Probar build localmente:
  ```bash
  docker build -t test-image .
  docker run -p 3000:3000 test-image
  ```

## 🔐 GitHub Configuration

### Secrets

- [ ] Generar KUBECONFIG:
  ```bash
  cat ~/.kube/config | base64
  ```
- [ ] Agregar secret `KUBECONFIG` en GitHub
  - Ir a: Settings → Secrets and variables → Actions
  - New repository secret
  - Name: `KUBECONFIG`
  - Value: [output del comando anterior]

- [ ] Secrets adicionales (si es necesario):
  - [ ] `DOCKERHUB_USERNAME` (si usas Docker Hub)
  - [ ] `DOCKERHUB_TOKEN` (si usas Docker Hub)
  - [ ] `DATABASE_URL` (si usas base de datos externa)
  - [ ] Otros secrets específicos de tu app

### Permisos

- [ ] Configurar permisos de GitHub Actions:
  - Ir a: Settings → Actions → General
  - Workflow permissions:
    - [ ] ✅ Read and write permissions
    - [ ] ✅ Allow GitHub Actions to create and approve pull requests

- [ ] Habilitar GitHub Actions:
  - [ ] Settings → Actions → General → Actions permissions
  - [ ] Seleccionar "Allow all actions and reusable workflows"

### Packages (para GHCR)

Si usas GitHub Container Registry:

- [ ] Ir a Packages en tu perfil/organización
- [ ] Encontrar el paquete cuando se cree
- [ ] Package settings → Manage Actions access
- [ ] Asegurar que el repositorio tiene "Write" access

## 🌐 DNS y Red

- [ ] Verificar que el DNS wildcard está configurado:
  ```bash
  nslookup pr-1.preview.jelou.dev
  # Debe resolver a la IP del Load Balancer
  ```

- [ ] Obtener IP del Ingress Controller:
  ```bash
  kubectl get svc -n ingress-nginx
  # Buscar EXTERNAL-IP
  ```

- [ ] Configurar registro DNS A:
  ```
  *.preview.jelou.dev  →  A  →  [EXTERNAL-IP]
  ```

## 🔒 SSL/TLS (Opcional pero recomendado)

- [ ] Verificar que cert-manager está instalado
- [ ] Crear ClusterIssuer para staging:
  ```bash
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
  EOF
  ```

- [ ] Crear ClusterIssuer para production:
  ```bash
  kubectl apply -f - <<EOF
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

- [ ] Verificar ClusterIssuers:
  ```bash
  kubectl get clusterissuer
  ```

## 🧪 Testing

### Test Local con Helm

- [ ] Hacer dry-run de Helm:
  ```bash
  helm install test-release ./helm \
    --dry-run \
    --debug \
    --set namespace=test \
    --set prNumber=999
  ```

- [ ] Validar template rendering:
  ```bash
  helm template test-release ./helm \
    --values ./helm/values-preview.yaml \
    --set namespace=test \
    --set prNumber=999 > /tmp/rendered.yaml

  # Revisar el archivo renderizado
  cat /tmp/rendered.yaml
  ```

### Test con PR Real

- [ ] Crear una rama de test:
  ```bash
  git checkout -b test/preview-env-setup
  git add .
  git commit -m "chore: setup preview environments"
  git push -u origin test/preview-env-setup
  ```

- [ ] Crear un Pull Request en GitHub

- [ ] Verificar que el workflow se ejecuta:
  - [ ] Ir a Actions tab
  - [ ] Ver el workflow "Deploy Preview Environment"
  - [ ] Verificar que todos los steps pasan

- [ ] Verificar el deployment:
  ```bash
  # Reemplazar 123 con el número de tu PR
  kubectl get all -n solar-system-pr-123
  ```

- [ ] Verificar el ingress:
  ```bash
  kubectl get ingress -n solar-system-pr-123
  ```

- [ ] Probar la URL del preview:
  - [ ] Abrir la URL comentada en el PR
  - [ ] Verificar que la app carga correctamente
  - [ ] Verificar funcionalidad básica

- [ ] Hacer un nuevo commit y verificar que se actualiza:
  ```bash
  echo "test" >> README.md
  git add README.md
  git commit -m "test: trigger redeploy"
  git push
  ```
  - [ ] Verificar que el workflow se ejecuta nuevamente
  - [ ] Verificar que el comentario del PR se actualiza

- [ ] Cerrar el PR y verificar cleanup:
  - [ ] Cerrar el PR (sin hacer merge)
  - [ ] Verificar que el workflow de cleanup se ejecuta
  - [ ] Verificar que el namespace se elimina:
    ```bash
    kubectl get namespace solar-system-pr-123
    # Debe mostrar "Not found"
    ```

## 📝 Documentación

- [ ] Copiar `PREVIEW_ENVIRONMENTS.md` al repositorio
- [ ] Copiar `QUICKSTART.md` al repositorio
- [ ] Actualizar `README.md` con:
  - [ ] Sección de Preview Environments
  - [ ] Badge de status de deployments
  - [ ] Enlaces a documentación

- [ ] Documentar configuraciones específicas:
  - [ ] Variables de entorno requeridas
  - [ ] Secrets necesarios
  - [ ] Configuración de base de datos
  - [ ] Cualquier paso adicional específico del proyecto

## 🎓 Team Onboarding

- [ ] Compartir documentación con el equipo
- [ ] Hacer demo del flujo de preview environments
- [ ] Documentar en Confluence/Wiki del equipo
- [ ] Agregar al proceso de onboarding de nuevos developers
- [ ] Compartir en canal de Slack del equipo

## ✅ Post-Setup

- [ ] Monitorear primeros PRs con preview environments
- [ ] Ajustar recursos si es necesario
- [ ] Documentar problemas encontrados y soluciones
- [ ] Recopilar feedback del equipo
- [ ] Iterar y mejorar la configuración

## 📊 Métricas (Opcional)

- [ ] Configurar monitoreo de preview environments
- [ ] Configurar alertas para failures
- [ ] Dashboard con métricas de uso
- [ ] Tracking de costos (si es necesario)

## 🔄 Mantenimiento Continuo

- [ ] Revisar y actualizar imágenes base regularmente
- [ ] Actualizar versiones de Helm charts
- [ ] Revisar límites de recursos según uso real
- [ ] Limpiar namespaces huérfanos periódicamente:
  ```bash
  # Listar todos los preview namespaces
  kubectl get namespaces -l environment=preview

  # Eliminar los que no correspondan a PRs activos
  ```

## 🎉 Completado

Una vez completado todo el checklist:

- [ ] Marcar el ticket/issue como completado
- [ ] Notificar al equipo
- [ ] Celebrar con el equipo 🎉

---

**Fecha de inicio:** ___________
**Fecha de completado:** ___________
**Responsable:** ___________
**Revisado por:** ___________

## 📞 Soporte

Si tienes problemas durante el setup:

- 📖 Consulta [PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md#troubleshooting)
- 💬 Canal de Slack: `#devops`
- ✉️ Email: devops@jelou.ai
- 🎫 Crea un ticket en Jira con label `preview-environments`
