# Guía de Desarrollo Local con Skaffold

## Requisitos previos
- Equipo configurado según `PREREQUISITES.md`
- Git configurado con tu nombre: `git config user.name "TuNombre"`

## Iniciar desarrollo
```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd <nombre-del-repo>

# 2. Crear tu branch de feature
git checkout -b feature-mi-cambio

# 3. Iniciar ambiente de desarrollo
./dev.sh
```

El script `dev.sh` automáticamente:
- Crea un namespace único para ti: `dev-tunombre-branch`
- Construye las imágenes
- Despliega en Kubernetes
- Abre port-forward a tu app

## Comandos útiles
```bash
# Ver pods en tu namespace
kubectl get pods -n $DEV_NAMESPACE

# Ver logs de la app
kubectl logs -l app=<nombre-app> -n $DEV_NAMESPACE

# Entrar a un pod
kubectl exec -it <pod-name> -n $DEV_NAMESPACE -- sh

# Limpiar tu ambiente
skaffold delete
kubectl delete namespace $DEV_NAMESPACE
```

## Flujo de trabajo

1. Haces cambios en el código
2. Skaffold detecta los cambios automáticamente
3. Reconstruye la imagen
4. Redespliega en tu namespace
5. Pruebas en el navegador

## Solución de problemas

### Puerto ya en uso
```bash
skaffold delete
./dev.sh
```

### Namespace no existe
```bash
kubectl create namespace $DEV_NAMESPACE
```

### Ver todos los namespaces de desarrollo
```bash
kubectl get namespaces | grep dev-
```

### Limpiar todo
```bash
skaffold delete
kubectl delete namespace $DEV_NAMESPACE
```