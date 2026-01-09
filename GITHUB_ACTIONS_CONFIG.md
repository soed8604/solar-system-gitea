# Configuración de GitHub Actions

## ✅ Checklist de Configuración

### 1. Secret KUBECONFIG

- [ ] Ve a: https://github.com/soed8604/solar-system-gitea/settings/secrets/actions
- [ ] Click en "New repository secret"
- [ ] Name: `KUBECONFIG`
- [ ] Secret: [El valor en base64 que copiaste]
- [ ] Click "Add secret"

### 2. Permisos de GitHub Actions

- [ ] Ve a: https://github.com/soed8604/solar-system-gitea/settings/actions
- [ ] En "Workflow permissions", selecciona:
  - ✅ **Read and write permissions**
- [ ] Marca el checkbox:
  - ✅ **Allow GitHub Actions to create and approve pull requests**
- [ ] Click "Save"

### 3. Habilitar GitHub Actions (si está deshabilitado)

- [ ] Ve a: https://github.com/soed8604/solar-system-gitea/settings/actions
- [ ] En "Actions permissions", selecciona:
  - ✅ **Allow all actions and reusable workflows**
- [ ] Click "Save"

### 4. Paquete de GitHub Container Registry (GHCR)

Cuando se cree el primer paquete (después del primer PR):

- [ ] Ve a: https://github.com/soed8604?tab=packages
- [ ] Busca el paquete `solar-system-gitea`
- [ ] Entra al paquete
- [ ] Package settings → Change visibility → **Public**
  - (Esto permite que GitHub Actions pueda pushear sin autenticación adicional)

## 🔍 Verificación

Después de configurar todo:

- [ ] Los secrets aparecen en: https://github.com/soed8604/solar-system-gitea/settings/secrets/actions
- [ ] Los permisos están configurados correctamente
- [ ] GitHub Actions está habilitado

## 🚀 Siguiente Paso

Una vez configurado todo, crea un PR de prueba:

\`\`\`bash
# Crear rama de prueba
git checkout -b test/preview-env-validation

# Hacer un cambio pequeño
echo "## Testing Preview Environments" >> README.md

# Commit y push
git add README.md
git commit -m "test: validate preview environment deployment"
git push origin test/preview-env-validation
\`\`\`

Luego ve a GitHub y crea el Pull Request.
