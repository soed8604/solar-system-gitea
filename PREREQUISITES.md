# Preparación del Equipo Local

Este manual se realiza una sola vez para preparar tu máquina de desarrollo.

## 1. Instalar Rancher Desktop
```bash
brew install --cask rancher
```

### Configuración inicial:
1. Abrir Rancher Desktop desde Applications
2. Container Engine: seleccionar `dockerd (moby)`
3. Kubernetes: habilitar
4. Esperar 2-3 minutos que levante el cluster

## 2. Instalar Skaffold
```bash
brew install skaffold
```

## 3. Configurar Docker CLI
```bash
echo 'export PATH="$HOME/.rd/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
docker context use rancher-desktop
```

## 4. Verificar instalación
```bash
kubectl get nodes
docker ps
skaffold version
```

Si todos los comandos responden sin error, tu equipo está listo.
