#!/bin/bash
set -e

# =============================================================================
# Script para configurar OIDC entre GitHub Actions y AWS
# =============================================================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# CONFIGURACIÓN - Modifica estos valores según tu entorno
# -----------------------------------------------------------------------------
GITHUB_ORG="soed8604"                          # Tu usuario/organización de GitHub
GITHUB_REPO="solar-system-gitea"               # Nombre del repositorio
AWS_REGION="us-west-2"                         # Región AWS
EKS_CLUSTER_NAME="cluster-k8s-staging"         # Nombre del cluster EKS
ROLE_NAME="GitHubActions-EKS-Deploy"           # Nombre del rol IAM a crear

# -----------------------------------------------------------------------------
# Obtener Account ID automáticamente
# -----------------------------------------------------------------------------
echo -e "${YELLOW}Obteniendo Account ID de AWS...${NC}"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}Account ID: ${AWS_ACCOUNT_ID}${NC}"

# -----------------------------------------------------------------------------
# 1. Crear el OIDC Provider para GitHub (si no existe)
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Paso 1: Verificando OIDC Provider para GitHub...${NC}"

OIDC_PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

if aws iam get-open-id-connect-provider --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" 2>/dev/null; then
    echo -e "${GREEN}OIDC Provider ya existe${NC}"
else
    echo -e "${YELLOW}Creando OIDC Provider...${NC}"
    aws iam create-open-id-connect-provider \
        --url "https://token.actions.githubusercontent.com" \
        --client-id-list "sts.amazonaws.com" \
        --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1" "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
    echo -e "${GREEN}OIDC Provider creado exitosamente${NC}"
fi

# -----------------------------------------------------------------------------
# 2. Crear la política de confianza (Trust Policy)
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Paso 2: Creando Trust Policy...${NC}"

TRUST_POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:*"
                }
            }
        }
    ]
}
EOF
)

# -----------------------------------------------------------------------------
# 3. Crear la política de permisos para EKS
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Paso 3: Creando política de permisos para EKS...${NC}"

POLICY_NAME="GitHubActions-EKS-Policy"
POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}"

EKS_POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EKSDescribe",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EKSAccess",
            "Effect": "Allow",
            "Action": [
                "eks:AccessKubernetesApi"
            ],
            "Resource": "arn:aws:eks:${AWS_REGION}:${AWS_ACCOUNT_ID}:cluster/${EKS_CLUSTER_NAME}"
        }
    ]
}
EOF
)

# Verificar si la política existe
if aws iam get-policy --policy-arn "$POLICY_ARN" 2>/dev/null; then
    echo -e "${GREEN}Política ${POLICY_NAME} ya existe${NC}"
else
    echo -e "${YELLOW}Creando política ${POLICY_NAME}...${NC}"
    aws iam create-policy \
        --policy-name "$POLICY_NAME" \
        --policy-document "$EKS_POLICY"
    echo -e "${GREEN}Política creada exitosamente${NC}"
fi

# -----------------------------------------------------------------------------
# 4. Crear el rol IAM
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Paso 4: Creando rol IAM ${ROLE_NAME}...${NC}"

if aws iam get-role --role-name "$ROLE_NAME" 2>/dev/null; then
    echo -e "${GREEN}Rol ${ROLE_NAME} ya existe${NC}"
    echo -e "${YELLOW}Actualizando trust policy...${NC}"
    aws iam update-assume-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-document "$TRUST_POLICY"
else
    echo -e "${YELLOW}Creando rol...${NC}"
    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document "$TRUST_POLICY" \
        --description "Rol para GitHub Actions - Deploy a EKS"
    echo -e "${GREEN}Rol creado exitosamente${NC}"
fi

# -----------------------------------------------------------------------------
# 5. Adjuntar la política al rol
# -----------------------------------------------------------------------------
echo -e "\n${YELLOW}Paso 5: Adjuntando política al rol...${NC}"

aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "$POLICY_ARN" 2>/dev/null || true

echo -e "${GREEN}Política adjuntada exitosamente${NC}"

# -----------------------------------------------------------------------------
# 6. Mostrar información para configurar GitHub
# -----------------------------------------------------------------------------
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"

echo -e "\n${GREEN}=============================================================================${NC}"
echo -e "${GREEN}CONFIGURACIÓN COMPLETADA${NC}"
echo -e "${GREEN}=============================================================================${NC}"
echo -e "\n${YELLOW}Información para GitHub Actions:${NC}"
echo -e "  Role ARN: ${GREEN}${ROLE_ARN}${NC}"
echo -e "  Region:   ${GREEN}${AWS_REGION}${NC}"
echo -e "\n${YELLOW}Configura este secret en tu repositorio de GitHub:${NC}"
echo -e "  Settings → Secrets and variables → Actions → New repository secret"
echo -e "  Name:  ${GREEN}AWS_ROLE_ARN${NC}"
echo -e "  Value: ${GREEN}${ROLE_ARN}${NC}"
echo -e "\n${YELLOW}IMPORTANTE: Configura el acceso en EKS${NC}"
echo -e "  Ejecuta el siguiente comando para dar acceso al rol en el cluster:"
echo -e ""
echo -e "  ${GREEN}aws eks create-access-entry --cluster-name ${EKS_CLUSTER_NAME} --principal-arn ${ROLE_ARN} --type STANDARD --region ${AWS_REGION}${NC}"
echo -e ""
echo -e "  ${GREEN}aws eks associate-access-policy --cluster-name ${EKS_CLUSTER_NAME} --principal-arn ${ROLE_ARN} --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster --region ${AWS_REGION}${NC}"
echo -e ""
echo -e "${GREEN}=============================================================================${NC}"
