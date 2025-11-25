#!/bin/bash

# Script para crear todos los recursos de Azure desde cero
# Ejecutar después de hacer 'az login'

set -e  # Salir si hay algún error

echo "🚀 Iniciando creación de recursos en Azure..."
echo ""

# Variables
RESOURCE_GROUP="rg-device-management"
LOCATION="eastus2"
ACR_NAME="devicemanagementacr"
APP_SERVICE_PLAN="asp-device-management"
BACKEND_APP="device-backend-app"
FRONTEND_APP="device-frontend-app"
APP_INSIGHTS="device-management-insights"

# 1. Crear Resource Group
echo "📦 [1/7] Creando Resource Group: $RESOURCE_GROUP"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --output table

echo "✅ Resource Group creado"
echo ""

# 2. Crear Azure Container Registry
echo "🐳 [2/7] Creando Azure Container Registry: $ACR_NAME"
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true \
  --output table

echo "✅ Container Registry creado"
echo ""

# 3. Crear Application Insights
echo "📊 [3/7] Creando Application Insights: $APP_INSIGHTS"
az monitor app-insights component create \
  --app $APP_INSIGHTS \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web \
  --output table

echo "✅ Application Insights creado"
echo ""

# 4. Crear App Service Plan
echo "⚙️ [4/7] Creando App Service Plan: $APP_SERVICE_PLAN"
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku B1 \
  --output table

echo "✅ App Service Plan creado"
echo ""

# 5. Crear Web App Backend
echo "🔧 [5/7] Creando Web App Backend: $BACKEND_APP"
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $BACKEND_APP \
  --deployment-container-image-name mcr.microsoft.com/appsvc/staticsite:latest \
  --output table

echo "✅ Web App Backend creada"
echo ""

# 6. Crear Web App Frontend
echo "🎨 [6/7] Creando Web App Frontend: $FRONTEND_APP"
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $FRONTEND_APP \
  --deployment-container-image-name mcr.microsoft.com/appsvc/staticsite:latest \
  --output table

echo "✅ Web App Frontend creada"
echo ""

# 7. Configurar Web Apps para usar ACR
echo "🔗 [7/7] Configurando Web Apps con Container Registry..."

# Obtener credenciales del ACR
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)

# Configurar backend
az webapp config container set \
  --name $BACKEND_APP \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_LOGIN_SERVER/device-backend:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-user $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD

# Configurar frontend
az webapp config container set \
  --name $FRONTEND_APP \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_LOGIN_SERVER/device-frontend:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-user $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD

# Configurar puerto del backend
az webapp config appsettings set \
  --name $BACKEND_APP \
  --resource-group $RESOURCE_GROUP \
  --settings WEBSITES_PORT=3000

echo "✅ Configuración completada"
echo ""

# Obtener Application Insights Connection String
echo "📝 Obteniendo información importante..."
APP_INSIGHTS_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query connectionString \
  --output tsv)

echo ""
echo "=========================================="
echo "✅ ¡TODOS LOS RECURSOS CREADOS!"
echo "=========================================="
echo ""
echo "📋 URLs de tus aplicaciones:"
echo "   Backend:  https://$BACKEND_APP.azurewebsites.net"
echo "   Frontend: https://$FRONTEND_APP.azurewebsites.net"
echo ""
echo "📋 Información para GitHub Secrets:"
echo "   ACR_USERNAME: $ACR_USERNAME"
echo "   ACR_PASSWORD: $ACR_PASSWORD"
echo "   APPLICATIONINSIGHTS_CONNECTION_STRING:"
echo "   $APP_INSIGHTS_KEY"
echo ""
echo "⚠️  IMPORTANTE: Guarda esta información para configurar GitHub Secrets"
echo ""
echo "📦 Próximo paso: Build y push de imágenes Docker"
echo ""
