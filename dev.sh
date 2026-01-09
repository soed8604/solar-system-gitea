#!/bin/bash

# Obtener nombre del dev y branch
DEV_NAME=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
BRANCH=$(git branch --show-current)

# Si no hay nombre configurado en git, usar el usuario del sistema
if [ -z "$DEV_NAME" ]; then
  DEV_NAME=$(whoami)
fi

export DEV_NAMESPACE="dev-${DEV_NAME}-${BRANCH}"

echo "🚀 Developer: $DEV_NAME"
echo "🌿 Branch: $BRANCH"
echo "📦 Namespace: $DEV_NAMESPACE"
echo ""

# Crear namespace si no existe
kubectl create namespace $DEV_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Iniciar skaffold
skaffold dev
