# 🚀 Instrucciones para Crear el PR de Prueba

## ✅ Todo está listo!

Has completado toda la configuración. Ahora vamos a crear un Pull Request de prueba para validar que el flujo completo funciona.

## 📝 Paso 1: Crear el Pull Request

**Abre este link en tu navegador:**

👉 **https://github.com/soed8604/solar-system-gitea/pull/new/test/preview-env-validation**

O manualmente:

1. Ve a: https://github.com/soed8604/solar-system-gitea
2. Verás un banner amarillo que dice "test/preview-env-validation had recent pushes"
3. Click en "Compare & pull request"

## 📋 Paso 2: Configurar el PR

**Título:**
```
test: validate preview environment deployment
```

**Descripción:**
```
Testing the automatic preview environment deployment workflow.

This PR will:
- ✅ Build Docker image and push to GHCR
- ✅ Deploy to EKS cluster
- ✅ Create isolated namespace
- ✅ Comment with access instructions
```

**Click en:** "Create pull request"

## 👀 Paso 3: Observar el Workflow

Una vez creado el PR:

1. **Ve a la pestaña "Actions"** en tu repositorio
2. Deberías ver un workflow ejecutándose: "Deploy Preview Environment"
3. Click en el workflow para ver los detalles

### Qué esperar:

El workflow tiene estos pasos:

1. ✅ **Checkout code** (5 segundos)
2. ✅ **Set up Docker Buildx** (10 segundos)
3. ✅ **Log in to Container Registry** (5 segundos)
4. ✅ **Extract metadata** (5 segundos)
5. ✅ **Build and push Docker image** (2-3 minutos) ← El más largo
6. ✅ **Set up kubectl** (5 segundos)
7. ✅ **Set up Helm** (5 segundos)
8. ✅ **Configure Kubernetes context** (5 segundos)
9. ✅ **Create namespace** (5 segundos)
10. ✅ **Deploy with Helm** (30-60 segundos)
11. ✅ **Comment PR with preview info** (5 segundos)

**Tiempo total estimado:** 3-4 minutos

## 🎉 Paso 4: Acceder al Preview Environment

Cuando el workflow termine exitosamente:

1. **Vuelve a la pestaña "Conversation" del PR**
2. Verás un comentario del bot con instrucciones
3. El comentario incluirá comandos como:

```bash
kubectl port-forward -n solar-system-pr-1 svc/solar-system-pr-1 3000:3000
```

4. **Copia y ejecuta ese comando en tu terminal**
5. **Abre en tu navegador:** http://localhost:3000
6. ¡Deberías ver la aplicación Solar System funcionando!

## 🐛 Si algo falla...

### Error: "failed to push: unauthorized"

**Causa:** El paquete GHCR necesita ser público

**Solución:**
1. Espera a que el workflow cree el paquete (aunque falle)
2. Ve a: https://github.com/soed8604?tab=packages
3. Click en el paquete "solar-system-gitea"
4. Package settings → Change visibility → Public
5. Re-ejecuta el workflow (botón "Re-run all jobs")

### Error: "error: You must be logged in to the server (Unauthorized)"

**Causa:** El KUBECONFIG secret no está configurado correctamente

**Solución:**
1. Verifica que el secret existe en: https://github.com/soed8604/solar-system-gitea/settings/secrets/actions
2. Regenera el KUBECONFIG:
   ```bash
   cat ~/.kube/config | base64 | pbcopy
   ```
3. Actualiza el secret en GitHub
4. Re-ejecuta el workflow

### Error: "insufficient permissions"

**Causa:** Los permisos de GitHub Actions no están configurados

**Solución:**
1. Ve a: https://github.com/soed8604/solar-system-gitea/settings/actions
2. Selecciona "Read and write permissions"
3. Marca "Allow GitHub Actions to create and approve pull requests"
4. Save y re-ejecuta el workflow

## 📊 Verificar Deployment en Kubernetes

Mientras el workflow corre o después, puedes verificar en tu cluster:

```bash
# Ver el namespace (reemplaza 1 con el número de tu PR)
kubectl get namespaces | grep solar-system-pr-1

# Ver todos los recursos
kubectl get all -n solar-system-pr-1

# Ver logs de la aplicación
kubectl logs -n solar-system-pr-1 -l app=solar-system --tail=50 -f

# Ver logs de MongoDB
kubectl logs -n solar-system-pr-1 -l app=mongodb --tail=50

# Ver eventos
kubectl get events -n solar-system-pr-1 --sort-by='.lastTimestamp'
```

## 🧹 Paso 5: Probar Cleanup

Una vez que hayas verificado que el preview funciona:

1. **Cierra el PR** (no hagas merge, solo cierra)
2. Ve a la pestaña "Actions"
3. Verás un nuevo workflow: "Cleanup Preview Environment"
4. Espera a que termine (1-2 minutos)
5. Verifica que el namespace fue eliminado:

```bash
kubectl get namespace solar-system-pr-1
# Debe mostrar: Error from server (NotFound)
```

## ✅ Checklist de Validación

Marca cada item al completarlo:

- [ ] PR creado exitosamente
- [ ] Workflow "Deploy Preview Environment" se ejecutó sin errores
- [ ] Comentario del bot aparece en el PR con instrucciones
- [ ] Namespace creado en Kubernetes
- [ ] Pods están corriendo (Running y Ready)
- [ ] Port-forward funciona
- [ ] Aplicación accesible en http://localhost:3000
- [ ] Aplicación muestra datos correctamente
- [ ] PR cerrado
- [ ] Workflow "Cleanup" se ejecutó
- [ ] Namespace eliminado de Kubernetes

## 🎊 ¡Éxito!

Si todo funcionó, ¡felicidades! Has configurado exitosamente preview environments en tu GitHub personal.

### Próximos pasos:

1. **Documenta aprendizajes** - Anota cualquier problema encontrado
2. **Comparte con el equipo** - Muestra la demo funcionando
3. **Prepara migración a JelouLatam** - Lee [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)

## 💬 Notas

Usa este espacio para anotar observaciones:

- Tiempo total del workflow: _____
- Problemas encontrados: _____
- Soluciones aplicadas: _____
- Mejoras sugeridas: _____

---

**¡Buena suerte con la prueba!** 🚀
