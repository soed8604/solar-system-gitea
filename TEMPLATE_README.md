# [Nombre de tu Aplicación]

> Template README para repositorios con Preview Environments

<!-- Badges opcionales -->
[![Deploy Status](https://github.com/JelouLatam/tu-repo/actions/workflows/pr-deploy.yml/badge.svg)](https://github.com/JelouLatam/tu-repo/actions/workflows/pr-deploy.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Descripción breve de tu aplicación.

## 🚀 Preview Environments

Este repositorio está configurado con **Preview Environments automáticos**. Cada Pull Request despliega automáticamente un entorno de prueba aislado.

### ¿Cómo funciona?

1. **Crea un PR** → GitHub Actions automáticamente despliega tu código
2. **Obtén una URL única** → `https://pr-123.preview.jelou.dev`
3. **Comparte y prueba** → Muestra los cambios al equipo antes del merge
4. **Cierra el PR** → El ambiente se limpia automáticamente

### URLs de Preview

Los preview environments se despliegan en:
```
https://pr-[número].preview.jelou.dev
```

Ejemplo: `https://pr-42.preview.jelou.dev`

## 📋 Requisitos

- Node.js 18+
- MongoDB 6+
- Docker (para desarrollo local)
- Kubernetes cluster (para preview environments)

## 🛠️ Desarrollo Local

### Instalación

```bash
# Clonar repositorio
git clone https://github.com/JelouLatam/tu-repo.git
cd tu-repo

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Edita .env con tus valores
```

### Ejecutar localmente

```bash
# Iniciar aplicación
npm start

# Ejecutar tests
npm test

# Ejecutar con hot-reload
npm run dev
```

### Desarrollo con Docker

```bash
# Build
docker build -t tu-aplicacion .

# Run
docker run -p 3000:3000 \
  -e MONGO_URI=mongodb://localhost:27017 \
  tu-aplicacion
```

### Desarrollo con Skaffold (Recomendado)

```bash
# Configurar namespace de desarrollo
export DEV_NAMESPACE=tu-namespace-dev

# Iniciar desarrollo
skaffold dev

# Tu app estará disponible en http://localhost:3000
```

## 🏗️ Arquitectura

```
├── helm/                   # Helm chart para Kubernetes
│   ├── Chart.yaml
│   ├── values.yaml         # Configuración por defecto
│   ├── values-preview.yaml # Configuración para PRs
│   └── templates/          # Templates de Kubernetes
├── .github/
│   └── workflows/
│       ├── pr-deploy.yml   # Deploy automático de PRs
│       └── pr-cleanup.yml  # Limpieza automática
├── src/                    # Código fuente
├── tests/                  # Tests
├── Dockerfile              # Imagen Docker
└── skaffold.yaml           # Configuración de Skaffold
```

## 📦 Stack Tecnológico

- **Runtime:** Node.js 18
- **Framework:** Express
- **Base de Datos:** MongoDB 6
- **Containerización:** Docker
- **Orquestación:** Kubernetes + Helm
- **CI/CD:** GitHub Actions
- **Desarrollo Local:** Skaffold

## 🧪 Testing

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# Coverage
npm run coverage

# Linting
npm run lint

# Format
npm run format
```

## 🚢 Deployment

### Preview Environments (Automático)

Los preview environments se despliegan automáticamente al crear/actualizar un PR.

### Staging (Manual)

```bash
# Deploy a staging
helm upgrade --install tu-app ./helm \
  --namespace staging \
  --values helm/values-staging.yaml
```

### Production (GitHub Actions)

El deployment a producción se hace automáticamente al hacer merge a `main`:

```bash
# Se ejecuta automáticamente en GitHub Actions
# Ver .github/workflows/production-deploy.yml
```

## 🔧 Configuración

### Variables de Entorno

| Variable | Descripción | Default | Requerido |
|----------|-------------|---------|-----------|
| `MONGO_URI` | URI de MongoDB | - | ✅ |
| `MONGO_USERNAME` | Usuario de MongoDB | - | ✅ |
| `MONGO_PASSWORD` | Password de MongoDB | - | ✅ |
| `NODE_ENV` | Ambiente (dev/prod) | `development` | ❌ |
| `PORT` | Puerto de la app | `3000` | ❌ |

### Helm Values

Personaliza el deployment editando `helm/values.yaml`:

```yaml
app:
  replicaCount: 2  # Número de réplicas

resources:
  limits:
    cpu: 500m
    memory: 512Mi

ingress:
  enabled: true
  hosts:
    - host: tu-app.jelou.dev
```

## 📊 Monitoreo

### Logs

```bash
# Ver logs del preview environment
kubectl logs -n solar-system-pr-123 -l app=solar-system --tail=100 -f
```

### Métricas

```bash
# Ver uso de recursos
kubectl top pods -n solar-system-pr-123
```

### Health Checks

La aplicación expone estos endpoints:

- `GET /live` - Liveness probe
- `GET /ready` - Readiness probe
- `GET /health` - Health check general

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request
6. Espera el comentario con la URL del preview environment
7. Comparte la URL con el equipo para revisión

## 📝 Convenciones de Código

- Usamos ESLint + Prettier
- Seguimos [Conventional Commits](https://www.conventionalcommits.org/)
- Tests obligatorios para nuevas features
- Coverage mínimo: 80%

## 🐛 Troubleshooting

### El preview environment no se despliega

1. Revisa los logs de GitHub Actions
2. Verifica que los secrets estén configurados
3. Consulta [PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md#troubleshooting)

### La aplicación no inicia localmente

```bash
# Verifica las variables de entorno
cat .env

# Verifica que MongoDB esté corriendo
docker ps | grep mongo

# Verifica los logs
npm start 2>&1 | tee app.log
```

### Tests fallan

```bash
# Limpia cache de npm
npm cache clean --force

# Reinstala dependencias
rm -rf node_modules package-lock.json
npm install

# Ejecuta tests con verbose
npm test -- --verbose
```

## 📚 Documentación

- [Quick Start](./QUICKSTART.md) - Empieza en 5 minutos
- [Preview Environments](./PREVIEW_ENVIRONMENTS.md) - Guía completa
- [Development](./DEVELOPMENT.md) - Guía de desarrollo
- [API Docs](./docs/api.md) - Documentación de API
- [Deployment](./docs/deployment.md) - Guía de deployment

## 📄 License

[MIT](LICENSE) - ver archivo LICENSE para detalles

## 👥 Team

- **Maintainer:** [@tu-usuario](https://github.com/tu-usuario)
- **DevOps:** [@devops-team](https://github.com/orgs/JelouLatam/teams/devops)

## 🔗 Enlaces

- [Production](https://tu-app.jelou.dev)
- [Staging](https://staging.tu-app.jelou.dev)
- [Jira Board](https://jelou.atlassian.net/...)
- [Confluence Docs](https://jelou.atlassian.net/wiki/...)

---

**Powered by Preview Environments** - Deploy con confianza 🚀
