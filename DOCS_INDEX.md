# Documentación - Preview Environments

Índice completo de la documentación de Preview Environments para JelouLatam.

## 🎯 Empezar Aquí

### Para Developers

**¿Nuevo en el proyecto?** Empieza aquí:

1. **[QUICKSTART.md](./QUICKSTART.md)** ⚡
   - Configura preview environments en 5 minutos
   - Guía paso a paso con ejemplos
   - **Ideal para:** Developers que quieren empezar rápido

### Para DevOps/SRE

**¿Configurando un nuevo repositorio?** Sigue esta ruta:

1. **[SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)** ✅
   - Checklist completo de configuración
   - Verificación paso a paso
   - **Ideal para:** Asegurar que no se olvide nada

2. **[PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md)** 📚
   - Documentación completa y detallada
   - Arquitectura y configuración avanzada
   - Troubleshooting exhaustivo
   - **Ideal para:** Configuración avanzada y debugging

### Para Product Managers / Stakeholders

**¿Quieres entender qué son los preview environments?**

- Lee la sección [¿Qué son los Preview Environments?](./PREVIEW_ENVIRONMENTS.md#qué-son-los-preview-environments) en PREVIEW_ENVIRONMENTS.md
- Ve el diagrama de [Arquitectura](./PREVIEW_ENVIRONMENTS.md#arquitectura)

## 📚 Documentación Disponible

### Guías de Usuario

| Documento | Descripción | Audiencia | Tiempo de lectura |
|-----------|-------------|-----------|-------------------|
| [QUICKSTART.md](./QUICKSTART.md) | Setup rápido en 5 minutos | Developers | 5 min |
| [PREVIEW_ENVIRONMENTS.md](./PREVIEW_ENVIRONMENTS.md) | Guía completa y detallada | DevOps, Developers | 30 min |
| [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) | Checklist de configuración | DevOps, SRE | 15 min |

### Plantillas

| Documento | Descripción | Uso |
|-----------|-------------|-----|
| [TEMPLATE_README.md](./TEMPLATE_README.md) | Template de README para repos | Copiar a nuevos repositorios |

### Archivos de Configuración

| Directorio/Archivo | Descripción | Propósito |
|-------------------|-------------|-----------|
| `helm/` | Helm chart completo | Deploy de la aplicación |
| `helm/Chart.yaml` | Metadata del chart | Versión y descripción |
| `helm/values.yaml` | Configuración por defecto | Valores base |
| `helm/values-preview.yaml` | Configuración de preview | Override para PRs |
| `helm/templates/` | Templates de Kubernetes | Recursos K8s |
| `.github/workflows/pr-deploy.yml` | Workflow de deploy | Automatización de deploy |
| `.github/workflows/pr-cleanup.yml` | Workflow de cleanup | Limpieza automática |
| `Dockerfile` | Imagen Docker | Containerización |
| `skaffold.yaml` | Configuración de Skaffold | Desarrollo local |

## 🗺️ Rutas de Aprendizaje

### Ruta 1: Developer - Primer Uso

```
1. QUICKSTART.md (Sección: Uso)
   ↓
2. Crear un PR de prueba
   ↓
3. Ver el preview environment desplegado
   ↓
4. QUICKSTART.md (Sección: Personalizar según tu stack)
```

### Ruta 2: Developer - Personalización

```
1. QUICKSTART.md (Sección: Variables de Entorno)
   ↓
2. QUICKSTART.md (Sección: Secrets)
   ↓
3. PREVIEW_ENVIRONMENTS.md (Sección: Configuración Avanzada)
   ↓
4. Modificar helm/values-preview.yaml
```

### Ruta 3: DevOps - Setup Inicial

```
1. PREVIEW_ENVIRONMENTS.md (Sección: Arquitectura)
   ↓
2. PREVIEW_ENVIRONMENTS.md (Sección: Requisitos Previos)
   ↓
3. SETUP_CHECKLIST.md (Todo el documento)
   ↓
4. PREVIEW_ENVIRONMENTS.md (Sección: Configuración Inicial)
   ↓
5. Test con PR real
   ↓
6. PREVIEW_ENVIRONMENTS.md (Sección: Troubleshooting) si es necesario
```

### Ruta 4: DevOps - Configuración Avanzada

```
1. PREVIEW_ENVIRONMENTS.md (Sección: Configuración Avanzada)
   ↓
2. Modificar templates de Helm según necesidad
   ↓
3. Agregar features al workflow de GitHub Actions
   ↓
4. Configurar monitoreo y métricas
```

### Ruta 5: Troubleshooting

```
¿Tienes un problema?
   ↓
1. PREVIEW_ENVIRONMENTS.md (Sección: Troubleshooting)
   ↓
   ¿Encontraste la solución?
   ├─ Sí → ¡Perfecto!
   └─ No → Contactar a DevOps (#devops en Slack)
```

## 🎓 Casos de Uso Comunes

### Caso 1: "Quiero deployar mi primer PR"

**Documentos:** QUICKSTART.md

**Pasos:**
1. Crea un PR
2. Espera el comentario con la URL
3. ¡Listo!

### Caso 2: "Necesito agregar variables de entorno"

**Documentos:** QUICKSTART.md → Variables de Entorno

**Pasos:**
1. Edita `helm/templates/deployment.yaml`
2. Agrega las env vars en la sección `env:`
3. Haz commit y push

### Caso 3: "Quiero usar PostgreSQL en lugar de MongoDB"

**Documentos:** QUICKSTART.md → Base de Datos, PREVIEW_ENVIRONMENTS.md → Configuración Avanzada

**Pasos:**
1. Desactiva MongoDB en `values.yaml`
2. Crea template `postgresql.yaml` basado en `mongodb.yaml`
3. Actualiza `deployment.yaml` con las env vars correctas

### Caso 4: "El preview environment no se despliega"

**Documentos:** PREVIEW_ENVIRONMENTS.md → Troubleshooting

**Pasos:**
1. Revisa logs de GitHub Actions
2. Busca el error en la sección de Troubleshooting
3. Aplica la solución
4. Si no lo encuentras, contacta DevOps

### Caso 5: "Quiero configurar esto en un nuevo repositorio"

**Documentos:** SETUP_CHECKLIST.md, PREVIEW_ENVIRONMENTS.md → Configuración Inicial

**Pasos:**
1. Sigue el SETUP_CHECKLIST.md paso a paso
2. Marca cada checkbox al completar
3. Haz un PR de prueba
4. Verifica que funcione

### Caso 6: "Necesito más recursos para mi preview"

**Documentos:** QUICKSTART.md → Recursos de Kubernetes

**Pasos:**
1. Edita `helm/values-preview.yaml`
2. Aumenta `resources.limits` y `resources.requests`
3. Haz commit y push

### Caso 7: "Quiero agregar tests antes del deploy"

**Documentos:** PREVIEW_ENVIRONMENTS.md → Configuración Avanzada → Agregar Tests Pre-Deploy

**Pasos:**
1. Edita `.github/workflows/pr-deploy.yml`
2. Agrega steps de testing antes del deploy
3. Haz commit y push

## 🔍 Búsqueda Rápida

### Por Tema

- **Instalación/Setup:** SETUP_CHECKLIST.md, PREVIEW_ENVIRONMENTS.md
- **Uso básico:** QUICKSTART.md
- **Configuración avanzada:** PREVIEW_ENVIRONMENTS.md
- **Troubleshooting:** PREVIEW_ENVIRONMENTS.md
- **Variables de entorno:** QUICKSTART.md, PREVIEW_ENVIRONMENTS.md
- **Secrets:** QUICKSTART.md, PREVIEW_ENVIRONMENTS.md
- **Base de datos:** QUICKSTART.md, PREVIEW_ENVIRONMENTS.md
- **SSL/TLS:** SETUP_CHECKLIST.md, PREVIEW_ENVIRONMENTS.md
- **Monitoreo:** PREVIEW_ENVIRONMENTS.md
- **Limpieza:** PREVIEW_ENVIRONMENTS.md

### Por Herramienta

- **Helm:** Todos los archivos en `helm/`, PREVIEW_ENVIRONMENTS.md
- **GitHub Actions:** `.github/workflows/`, PREVIEW_ENVIRONMENTS.md
- **Kubernetes:** PREVIEW_ENVIRONMENTS.md, SETUP_CHECKLIST.md
- **Docker:** Dockerfile, PREVIEW_ENVIRONMENTS.md
- **Skaffold:** skaffold.yaml, DEVELOPMENT.md

## 📖 Recursos Externos

- [Documentación de Helm](https://helm.sh/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Cert-Manager](https://cert-manager.io/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

## 💡 Tips

### Para leer más rápido

1. Usa la tabla de contenidos de cada documento
2. Busca con Ctrl+F / Cmd+F tu término específico
3. Consulta esta página de índice para encontrar el documento correcto

### Para contribuir a la documentación

1. Mantén el mismo formato y estructura
2. Agrega ejemplos prácticos
3. Actualiza este índice si agregas nueva documentación
4. Usa lenguaje claro y conciso

## 🆘 Soporte

Si no encuentras lo que buscas:

1. **Busca en la documentación:** Usa Ctrl+F en los documentos
2. **Revisa casos de uso:** Mira la sección "Casos de Uso Comunes" arriba
3. **Consulta Troubleshooting:** PREVIEW_ENVIRONMENTS.md tiene soluciones comunes
4. **Pregunta en Slack:** Canal `#devops`
5. **Email:** devops@jelou.ai

## 📝 Changelog

### 2026-01-05
- ✅ Documentación inicial completa
- ✅ QUICKSTART.md
- ✅ PREVIEW_ENVIRONMENTS.md
- ✅ SETUP_CHECKLIST.md
- ✅ TEMPLATE_README.md
- ✅ DOCS_INDEX.md
- ✅ Helm charts completos
- ✅ GitHub Actions workflows

## 🎯 Próximos Pasos

Después de leer esta documentación:

1. **Si eres Developer:**
   - Sigue el QUICKSTART.md
   - Crea un PR de prueba
   - Experimenta con el preview environment

2. **Si eres DevOps:**
   - Sigue el SETUP_CHECKLIST.md
   - Configura el primer repositorio
   - Comparte conocimiento con el equipo

3. **Para todos:**
   - Da feedback sobre la documentación
   - Comparte mejoras y sugerencias
   - Ayuda a otros del equipo

---

**Última actualización:** 2026-01-05
**Mantenido por:** Equipo DevOps JelouLatam
**Versión:** 1.0.0
