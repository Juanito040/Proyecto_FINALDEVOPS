# Script de Despliegue a Azure
# Device Management System

param(
    [string]$Component = "all"  # "backend", "frontend", o "all"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Despliegue a Azure - Device Management" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Configuración
$ACR_NAME = "devicemanagementacr"
$RESOURCE_GROUP = "rg-device-management"
$BACKEND_APP = "device-backend-app"
$FRONTEND_APP = "device-frontend-app"

# Función para manejar errores
function Handle-Error {
    param([string]$Message)
    Write-Host "❌ Error: $Message" -ForegroundColor Red
    exit 1
}

# Verificar Azure CLI
Write-Host "🔍 Verificando Azure CLI..." -ForegroundColor Yellow
try {
    az account show | Out-Null
} catch {
    Handle-Error "Azure CLI no está autenticado. Ejecuta 'az login' primero."
}
Write-Host "✅ Azure CLI autenticado" -ForegroundColor Green

# Construir imágenes Docker
if ($Component -eq "backend" -or $Component -eq "all") {
    Write-Host ""
    Write-Host "🏗️  Construyendo imagen del backend..." -ForegroundColor Yellow
    docker-compose build backend
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Falló la construcción del backend"
    }
    Write-Host "✅ Backend construido" -ForegroundColor Green
}

if ($Component -eq "frontend" -or $Component -eq "all") {
    Write-Host ""
    Write-Host "🏗️  Construyendo imagen del frontend..." -ForegroundColor Yellow
    docker-compose build frontend
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Falló la construcción del frontend"
    }
    Write-Host "✅ Frontend construido" -ForegroundColor Green
}

# Login en ACR
Write-Host ""
Write-Host "🔐 Autenticando en Azure Container Registry..." -ForegroundColor Yellow
az acr login --name $ACR_NAME
if ($LASTEXITCODE -ne 0) {
    Handle-Error "Falló la autenticación en ACR"
}
Write-Host "✅ Autenticado en ACR" -ForegroundColor Green

# Tagear y push imágenes
if ($Component -eq "backend" -or $Component -eq "all") {
    Write-Host ""
    Write-Host "🏷️  Tageando imagen del backend..." -ForegroundColor Yellow
    docker tag proyectodj-backend:latest "$ACR_NAME.azurecr.io/device-backend:latest"

    Write-Host "📤 Subiendo imagen del backend a ACR..." -ForegroundColor Yellow
    docker push "$ACR_NAME.azurecr.io/device-backend:latest"
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Falló el push del backend"
    }
    Write-Host "✅ Backend subido a ACR" -ForegroundColor Green
}

if ($Component -eq "frontend" -or $Component -eq "all") {
    Write-Host ""
    Write-Host "🏷️  Tageando imagen del frontend..." -ForegroundColor Yellow
    docker tag proyectodj-frontend:latest "$ACR_NAME.azurecr.io/device-frontend:latest"

    Write-Host "📤 Subiendo imagen del frontend a ACR..." -ForegroundColor Yellow
    docker push "$ACR_NAME.azurecr.io/device-frontend:latest"
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Falló el push del frontend"
    }
    Write-Host "✅ Frontend subido a ACR" -ForegroundColor Green
}

# Reiniciar Web Apps
if ($Component -eq "backend" -or $Component -eq "all") {
    Write-Host ""
    Write-Host "🔄 Reiniciando Web App del backend..." -ForegroundColor Yellow
    az webapp restart --name $BACKEND_APP --resource-group $RESOURCE_GROUP
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Falló el reinicio del backend"
    }
    Write-Host "✅ Backend reiniciado" -ForegroundColor Green
}

if ($Component -eq "frontend" -or $Component -eq "all") {
    Write-Host ""
    Write-Host "🔄 Reiniciando Web App del frontend..." -ForegroundColor Yellow
    az webapp restart --name $FRONTEND_APP --resource-group $RESOURCE_GROUP
    if ($LASTEXITCODE -ne 0) {
        Handle-Error "Falló el reinicio del frontend"
    }
    Write-Host "✅ Frontend reiniciado" -ForegroundColor Green
}

# Resumen
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✨ Despliegue Completado!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URLs de acceso:" -ForegroundColor Yellow
if ($Component -eq "backend" -or $Component -eq "all") {
    Write-Host "  Backend:  https://$BACKEND_APP.azurewebsites.net" -ForegroundColor Cyan
}
if ($Component -eq "frontend" -or $Component -eq "all") {
    Write-Host "  Frontend: https://$FRONTEND_APP.azurewebsites.net" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Monitoreo:" -ForegroundColor Yellow
Write-Host "  Application Insights: https://portal.azure.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver logs:" -ForegroundColor Yellow
Write-Host "  az webapp log tail --name $BACKEND_APP --resource-group $RESOURCE_GROUP" -ForegroundColor Gray
Write-Host ""
