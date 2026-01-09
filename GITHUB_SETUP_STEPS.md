# Pasos para Subir a GitHub Personal

Sigue estos pasos exactamente como se indican.

## Paso 1: Crear Repositorio en GitHub

1. **Abre tu navegador** y ve a: https://github.com/new

2. **Configura el repositorio:**
   - **Repository name:** `solar-system-gitea` (o el nombre que prefieras)
   - **Description:** "Solar System app with Preview Environments - Testing"
   - **Visibility:**
     - ✅ Public (recomendado para usar GHCR gratis)
     - ⚠️ Private (si prefieres, pero necesitarás configurar más permisos)
   - **NO** marques ninguna de estas opciones:
     - ❌ Add a README file
     - ❌ Add .gitignore
     - ❌ Choose a license

3. **Click en "Create repository"**

4. **Copia la URL SSH** que aparece (será algo como):
   ```
   git@github.com:TU-USUARIO/solar-system-gitea.git
   ```

   O la URL HTTPS (si no tienes SSH configurado):
   ```
   https://github.com/TU-USUARIO/solar-system-gitea.git
   ```

## Paso 2: Vuelve a esta terminal

Una vez que tengas la URL, dime cuál es tu usuario de GitHub y continuaremos con los comandos.

---

**¿Tienes SSH configurado en GitHub?**

- ✅ **Sí:** Usaremos la URL SSH (`git@github.com:...`)
- ❌ **No:** Usaremos HTTPS (`https://github.com/...`)

**¿Cómo saber?**

Ejecuta:
```bash
ssh -T git@github.com
```

Si dice "successfully authenticated", tienes SSH configurado.
Si da error o timeout, usa HTTPS.
