# 🔧 Fix: Configurar Credenciales de AWS para GitHub Actions

## 🔍 Problema Detectado

El workflow falla con:
```
The config profile (jelou-demo) could not be found
error: getting credentials: exec: executable aws failed with exit code 255
```

**Causa:** Tu cluster EKS requiere credenciales de AWS, pero GitHub Actions no las tiene.

## ✅ Solución: Agregar Secrets de AWS

### Paso 1: Obtener tus credenciales de AWS

En tu terminal local, ejecuta:

```bash
# Opción A: Si usas el perfil jelou-demo
cat ~/.aws/credentials | grep -A 2 "\[jelou-demo\]"

# Opción B: Si usas el perfil default
cat ~/.aws/credentials | grep -A 2 "\[default\]"
```

Deberías ver algo como:
```
[jelou-demo]
aws_access_key_id = AKIAXXXXXXXXXXXXXXXX
aws_secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Paso 2: Agregar Secrets en GitHub

Ve a: **https://github.com/soed8604/solar-system-gitea/settings/secrets/actions**

Agrega estos 3 secrets:

#### 1. AWS_ACCESS_KEY_ID
- Name: `AWS_ACCESS_KEY_ID`
- Secret: `AKIAXXXXXXXXXXXXXXXX` (tu access key)

#### 2. AWS_SECRET_ACCESS_KEY
- Name: `AWS_SECRET_ACCESS_KEY`
- Secret: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (tu secret key)

#### 3. AWS_REGION
- Name: `AWS_REGION`
- Secret: `us-west-2` (basado en tu cluster URL)

### Paso 3: Actualizar el Workflow

El workflow necesita configurar las credenciales de AWS antes de usar kubectl.

## 🚀 Implementación Automática

Ejecutaré los cambios necesarios en el workflow para usar las credenciales de AWS.
