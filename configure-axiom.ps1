# Script para Configurar Axiom en Azure Web App
# Device Management System

param(
    [Parameter(Mandatory=$true)]
    [string]$AxiomToken,

    [Parameter(Mandatory=$true)]
    [string]$AxiomDataset
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuración de Axiom" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Configuración
$RESOURCE_GROUP = "rg-device-management"
$BACKEND_APP = "device-backend-app"

# Verificar Azure CLI
Write-Host "🔍 Verificando Azure CLI..." -ForegroundColor Yellow
try {
    az account show | Out-Null
} catch {
    Write-Host "❌ Error: Azure CLI no está autenticado. Ejecuta 'az login' primero." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Azure CLI autenticado" -ForegroundColor Green

# Configurar variables de entorno
Write-Host ""
Write-Host "⚙️  Configurando variables de entorno de Axiom..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $BACKEND_APP `
    --resource-group $RESOURCE_GROUP `
    --settings `
        AXIOM_TOKEN="$AxiomToken" `
        AXIOM_DATASET="$AxiomDataset"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al configurar variables de entorno" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Variables configuradas" -ForegroundColor Green

# Reiniciar Web App
Write-Host ""
Write-Host "🔄 Reiniciando backend para aplicar cambios..." -ForegroundColor Yellow
az webapp restart --name $BACKEND_APP --resource-group $RESOURCE_GROUP

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al reiniciar la aplicación" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Backend reiniciado" -ForegroundColor Green

# Resumen
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ✨ Axiom Configurado!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dataset: $AxiomDataset" -ForegroundColor Cyan
Write-Host ""
Write-Host "Los logs ahora se enviarán a:" -ForegroundColor Yellow
Write-Host "  - Application Insights (Azure)" -ForegroundColor Cyan
Write-Host "  - Axiom ($AxiomDataset)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ver logs en Axiom:" -ForegroundColor Yellow
Write-Host "  https://app.axiom.co/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Espera 1-2 minutos para que los logs empiecen a aparecer." -ForegroundColor Gray
Write-Host ""
