# Guía de Migración: GitHub Personal → GitHub Empresarial

Esta guía muestra exactamente qué cambiar cuando migres de tu prueba en GitHub personal a la implementación en JelouLatam.

## 📊 Comparación Rápida

| Configuración | GitHub Personal (Prueba) | GitHub JelouLatam (Producción) |
|---------------|-------------------------|--------------------------------|
| **Usuario/Org** | `tu-usuario` | `JelouLatam` |
| **Registry** | `ghcr.io/tu-usuario/solar-system-gitea` | `ghcr.io/jeloulatam/solar-system-gitea` |
| **Dominio** | `preview.tu-dominio.com` o sin dominio | `preview.jelou.dev` |
| **Cert-Manager** | Opcional | Recomendado |
| **Ingress** | Puede estar deshabilitado | Habilitado |
| **Recursos** | Mínimos | Según políticas |
| **Namespace** | `solar-system-pr-X` | `solar-system-pr-X` |

## 🔄 Cambios Necesarios

### 1. helm/values-preview.yaml

#### Para Prueba Personal (SIN dominio):

```yaml
ingress:
  enabled: false  # ← CAMBIAR: Deshabilitar ingress
```

#### Para Prueba Personal (CON dominio propio):

```yaml
ingress:
  enabled: true
  annotations:
    # Comentar si no tienes cert-manager
    # cert-manager.io/cluster-issuer: letsencrypt-staging
    nginx.ingress.kubernetes.io/ssl-redirect: "false"  # ← Sin SSL
  hosts:
    - host: "pr-{{ .Values.prNumber }}.preview.TU-DOMINIO.com"  # ← TU DOMINIO
      paths:
        - path: /
          pathType: Prefix
  tls: []  # ← Sin TLS
```

#### Para JelouLatam (Producción):

```yaml
ingress:
  enabled: true  # ← Habilitado
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging  # ← Con cert-manager
    nginx.ingress.kubernetes.io/ssl-redirect: "true"  # ← Con SSL
  hosts:
    - host: "pr-{{ .Values.prNumber }}.preview.jelou.dev"  # ← Dominio JelouLatam
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: "solar-system-pr-{{ .Values.prNumber }}-tls"
      hosts:
        - "pr-{{ .Values.prNumber }}.preview.jelou.dev"
```

### 2. .github/workflows/pr-deploy.yml

#### Líneas que cambian automáticamente (¡No requieren cambios!):

```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}  # ← Automáticamente usa tu usuario/org
```

Cuando el repo esté en JelouLatam, `${{ github.repository }}` será `JelouLatam/solar-system-gitea` automáticamente.

#### Líneas a verificar/ajustar:

**Línea ~53** - Namespace prefix (opcional, cambiar si quieres otro nombre):

```yaml
# Personal o JelouLatam - mismo formato
NAMESPACE="solar-system-pr-${{ github.event.pull_request.number }}"
```

**Línea ~82** - Get preview URL (solo si tienes ingress habilitado):

```yaml
# Para prueba personal SIN ingress, comentar este step completo
- name: Get preview URL
  id: preview-url
  run: |
    NAMESPACE="solar-system-pr-${{ github.event.pull_request.number }}"
    # Esto fallará si ingress.enabled=false, está OK
    INGRESS_HOST=$(kubectl get ingress -n $NAMESPACE -o jsonpath='{.items[0].spec.rules[0].host}' || echo "N/A")
    echo "url=https://${INGRESS_HOST}" >> $GITHUB_OUTPUT
```

**Línea ~90** - Comentario en PR (ajustar para incluir port-forward si no hay ingress):

Para prueba personal SIN ingress, actualizar el comentario:

```yaml
- name: Comment PR with preview URL
  uses: actions/github-script@v7
  with:
    script: |
      const prNumber = context.payload.pull_request.number;
      const namespace = \`solar-system-pr-\${prNumber}\`;

      // Para pruebas SIN ingress
      const comment = \`## 🚀 Preview Environment Deployed

      Your preview environment has been successfully deployed!

      **Namespace:** \\\`\${namespace}\\\`
      **Commit:** \\\`\${context.sha.substring(0, 7)}\\\`

      ### Acceder al preview:

      \\\`\\\`\\\`bash
      kubectl port-forward -n \${namespace} svc/solar-system-pr-\${prNumber} 3000:3000
      \\\`\\\`\\\`

      Luego abre: http://localhost:3000

      ---
      *Deployed by GitHub Actions*\`;

      // ... resto del código
```

Para JelouLatam CON ingress, dejar como está:

```yaml
const previewUrl = '${{ steps.preview-url.outputs.url }}';

const comment = \`## 🚀 Preview Environment Deployed

**Preview URL:** \${previewUrl}
**Namespace:** \\\`\${namespace}\\\`
**Commit:** \\\`\${context.sha.substring(0, 7)}\\\`

---
*Deployed by GitHub Actions*\`;
```

### 3. .github/workflows/pr-cleanup.yml

**¡No requiere cambios!** Funciona igual en personal y JelouLatam.

Solo verifica que el namespace prefix coincida:

```yaml
NAMESPACE="solar-system-pr-${{ github.event.pull_request.number }}"
```

### 4. helm/values.yaml

#### Líneas a cambiar:

**Línea 7** - Namespace por defecto (personal vs empresa):

```yaml
# Personal
namespace: solar-system-personal

# JelouLatam
namespace: solar-system-dev
```

**Línea 14-16** - Imagen del registry:

```yaml
# Personal
image:
  repository: ghcr.io/tu-usuario/solar-system-gitea
  pullPolicy: IfNotPresent
  tag: "latest"

# JelouLatam
image:
  repository: ghcr.io/jeloulatam/solar-system-gitea
  pullPolicy: IfNotPresent
  tag: "latest"
```

**Línea 22-30** - Ingress:

```yaml
# Personal (SIN dominio)
ingress:
  enabled: false

# Personal (CON dominio)
ingress:
  enabled: true
  hosts:
    - host: solar-system.preview.tu-dominio.com

# JelouLatam
ingress:
  enabled: true
  hosts:
    - host: solar-system.preview.jelou.dev
```

## 🔐 Secrets de GitHub

### GitHub Personal

```bash
# Solo necesitas KUBECONFIG
# Settings → Secrets → Actions → New secret

# Nombre: KUBECONFIG
# Valor:
cat ~/.kube/config | base64
```

### GitHub JelouLatam

```bash
# El equipo de DevOps configurará:
# 1. KUBECONFIG (del cluster empresarial)
# 2. Posiblemente otros secrets según políticas

# Contactar a DevOps para configuración
```

## ✅ Checklist de Migración

### Pre-Migración (Validación Personal)

- [ ] Prueba funcionando en tu GitHub personal
- [ ] Documentados todos los problemas encontrados
- [ ] Documentadas todas las soluciones aplicadas
- [ ] Screenshots/evidencia del funcionamiento
- [ ] Tiempos de deployment medidos

### Preparación para JelouLatam

- [ ] Crear fork/branch en organización JelouLatam
- [ ] Actualizar `helm/values.yaml`:
  - [ ] `namespace: solar-system-dev`
  - [ ] `image.repository: ghcr.io/jeloulatam/...`
- [ ] Actualizar `helm/values-preview.yaml`:
  - [ ] `ingress.enabled: true`
  - [ ] `hosts[0].host: pr-X.preview.jelou.dev`
  - [ ] Habilitar cert-manager annotations
  - [ ] Habilitar sección `tls`
- [ ] Verificar `.github/workflows/`:
  - [ ] `pr-deploy.yml` - ajustar comentario de PR si es necesario
  - [ ] `pr-cleanup.yml` - verificar namespace prefix

### Configuración en JelouLatam

- [ ] Solicitar a DevOps:
  - [ ] Access al repositorio
  - [ ] Configuración de secret `KUBECONFIG`
  - [ ] Verificar permisos de GitHub Actions
  - [ ] Verificar que DNS `*.preview.jelou.dev` esté configurado
  - [ ] Verificar que cert-manager esté instalado
  - [ ] Verificar que ingress-nginx esté instalado

### Testing en JelouLatam

- [ ] Crear PR de prueba
- [ ] Verificar que workflow de deploy funciona
- [ ] Verificar que namespace se crea
- [ ] Verificar que pods se despliegan
- [ ] Verificar que ingress se crea
- [ ] Verificar que URL funciona
- [ ] Verificar que SSL funciona
- [ ] Cerrar PR y verificar cleanup

### Post-Migración

- [ ] Documentar configuración final
- [ ] Actualizar README del proyecto
- [ ] Compartir con equipo
- [ ] Presentar en standup/meeting
- [ ] Agregar a proceso de onboarding

## 📝 Template de Documentación Interna

Cuando migres a JelouLatam, documenta:

```markdown
# Solar System - Preview Environments

## URLs

- **Preview pattern:** `https://pr-{número}.preview.jelou.dev`
- **Ejemplo:** https://pr-42.preview.jelou.dev

## Configuración

- **Registry:** ghcr.io/jeloulatam/solar-system-gitea
- **Cluster:** [nombre del cluster]
- **Namespace pattern:** solar-system-pr-{número}
- **Ingress Controller:** nginx
- **Cert-Manager:** letsencrypt-staging

## Contacto

- **Owner:** @tu-usuario
- **DevOps:** @devops-team
- **Slack:** #solar-system

## Troubleshooting

Ver: [PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md#troubleshooting)
```

## 🎯 Diferencias Clave a Recordar

### Durante las Pruebas Personales:

1. **Registry:** Será `ghcr.io/tu-usuario/...`
2. **Dominio:** Puede no tener o usar uno personal
3. **Ingress:** Puede estar deshabilitado
4. **SSL/TLS:** Probablemente sin certificados
5. **Recursos:** Mínimos para ahorrar costos
6. **Access:** Port-forward para acceder

### En Producción JelouLatam:

1. **Registry:** Será `ghcr.io/jeloulatam/...`
2. **Dominio:** `*.preview.jelou.dev` configurado
3. **Ingress:** Habilitado y funcionando
4. **SSL/TLS:** Certificados automáticos con cert-manager
5. **Recursos:** Según políticas del equipo
6. **Access:** URLs públicas vía ingress

## 💡 Tips

1. **No hagas cambios directos en workflows** - Usa variables de GitHub que se adapten automáticamente
2. **Usa comments en YAML** - Documenta qué es para personal vs empresa
3. **Mantén un branch separado** - `personal-test` vs `main` para JelouLatam
4. **Git tags** - Usa tags para marcar versiones probadas:
   ```bash
   git tag -a v1.0.0-personal-validated -m "Validated in personal GitHub"
   git tag -a v1.0.0-jelou-production -m "Production ready for JelouLatam"
   ```

## 🔄 Proceso de Actualización Continua

Una vez en producción en JelouLatam:

```
Personal (Testing) ──→ JelouLatam (Production)
      ↑                        │
      │                        │
      └────────────────────────┘
         (Sync back fixes)
```

1. Prueba nuevas features en personal
2. Si funciona, crea PR en JelouLatam
3. Sync fixes críticos de vuelta a personal

---

**Última actualización:** 2026-01-05
**Versión:** 1.0.0
