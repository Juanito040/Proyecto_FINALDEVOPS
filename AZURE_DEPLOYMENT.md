# Azure Deployment Guide - Device Management System

## Recursos Creados en Azure

### Resource Group
- **Nombre**: `rg-device-management`
- **Región**: East US 2
- **ID**: `/subscriptions/1664afe0-9130-4c1f-a701-93b9d0b1b789/resourceGroups/rg-device-management`

### Application Insights
- **Nombre**: `device-management-insights`
- **Tipo**: Web Application
- **Connection String**: `InstrumentationKey=704bd0a1-b891-43e6-ba56-a18c58ba6178;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/;ApplicationId=ad6c45da-bad2-4280-a45d-3f6afbcdc90f`
- **Instrumentation Key**: `704bd0a1-b891-43e6-ba56-a18c58ba6178`
- **Portal URL**: https://portal.azure.com/#@99c674ca-c0c7-490a-ae8f-16172636f31b/resource/subscriptions/1664afe0-9130-4c1f-a701-93b9d0b1b789/resourceGroups/rg-device-management/providers/microsoft.insights/components/device-management-insights

### App Service Plan
- **Nombre**: `asp-device-management`
- **SKU**: Basic (B1)
- **Sistema Operativo**: Linux
- **Capacidad**: 1 instancia

### Azure Container Registry
- **Nombre**: `devicemanagementacr`
- **Login Server**: `devicemanagementacr.azurecr.io`
- **Admin User**: `devicemanagementacr`
- **Admin Password**: `D+jF/Hc/NIB/yxQsl3nANSXVLgso+UOJxE/c0oO11A+ACRAD+OIb`

### Web App - Backend
- **Nombre**: `device-backend-app`
- **URL**: https://device-backend-app.azurewebsites.net
- **Contenedor**: `devicemanagementacr.azurecr.io/device-backend:latest`
- **Puerto**: 3000

### Web App - Frontend
- **Nombre**: `device-frontend-app`
- **URL**: https://device-frontend-app.azurewebsites.net
- **Contenedor**: `devicemanagementacr.azurecr.io/device-frontend:latest`
- **Puerto**: 80

## Acceso a los Logs

### Application Insights (Azure)

1. **Portal de Azure**:
   - Ve a https://portal.azure.com
   - Busca "device-management-insights"
   - En el menú lateral, selecciona:
     - **Logs**: Para consultar logs usando Kusto Query Language (KQL)
     - **Transaction search**: Para buscar eventos específicos
     - **Live Metrics**: Para ver métricas en tiempo real
     - **Failures**: Para ver errores y excepciones
     - **Performance**: Para analizar el rendimiento

2. **Consultas KQL comunes**:

```kql
// Ver todos los traces de las últimas 24 horas
traces
| where timestamp > ago(24h)
| order by timestamp desc

// Ver solo errores
traces
| where severityLevel >= 3
| where timestamp > ago(24h)
| order by timestamp desc

// Ver excepciones
exceptions
| where timestamp > ago(24h)
| order by timestamp desc

// Ver requests HTTP
requests
| where timestamp > ago(1h)
| summarize count() by resultCode
```

### Axiom (Pendiente de Configuración)

Para habilitar logs en Axiom, necesitas configurar las siguientes variables de entorno:

1. **Obtén tu API Token de Axiom**:
   - Ve a https://app.axiom.co/
   - Settings → API Tokens
   - Crea un nuevo token con permisos de "Ingest"

2. **Crea o usa un Dataset**:
   - Ve a Datasets
   - Crea un nuevo dataset o usa uno existente
   - Anota el nombre del dataset

3. **Configura las variables de entorno en Azure**:

```bash
# Reemplaza YOUR_TOKEN y YOUR_DATASET con tus valores reales
az webapp config appsettings set \
  --name device-backend-app \
  --resource-group rg-device-management \
  --settings \
    AXIOM_TOKEN="YOUR_TOKEN" \
    AXIOM_DATASET="YOUR_DATASET"

# Reinicia la aplicación
az webapp restart \
  --name device-backend-app \
  --resource-group rg-device-management
```

4. **Ver logs en Axiom**:
   - Ve a https://app.axiom.co/
   - Selecciona tu dataset
   - Usa el Stream o Query para ver logs en tiempo real

## Despliegue y Actualización

### Actualizar la Aplicación

Cuando hagas cambios en tu código:

1. **Reconstruir las imágenes localmente**:
```bash
cd C:\Users\Juan Ramirez\Desktop\SEMESTRE\9\DEVOPS\ProyectoDJ
docker-compose build
```

2. **Login en ACR**:
```bash
az acr login --name devicemanagementacr
```

3. **Tagear y push las imágenes**:
```bash
docker tag proyectodj-backend:latest devicemanagementacr.azurecr.io/device-backend:latest
docker tag proyectodj-frontend:latest devicemanagementacr.azurecr.io/device-frontend:latest

docker push devicemanagementacr.azurecr.io/device-backend:latest
docker push devicemanagementacr.azurecr.io/device-frontend:latest
```

4. **Reiniciar las Web Apps**:
```bash
az webapp restart --name device-backend-app --resource-group rg-device-management
az webapp restart --name device-frontend-app --resource-group rg-device-management
```

### Scripts de Despliegue Rápido

Puedes usar estos comandos para despliegue rápido:

```bash
# Despliegue completo
cd C:\Users\Juan Ramirez\Desktop\SEMESTRE\9\DEVOPS\ProyectoDJ
docker-compose build && \
az acr login --name devicemanagementacr && \
docker tag proyectodj-backend:latest devicemanagementacr.azurecr.io/device-backend:latest && \
docker tag proyectodj-frontend:latest devicemanagementacr.azurecr.io/device-frontend:latest && \
docker push devicemanagementacr.azurecr.io/device-backend:latest && \
docker push devicemanagementacr.azurecr.io/device-frontend:latest && \
az webapp restart --name device-backend-app --resource-group rg-device-management && \
az webapp restart --name device-frontend-app --resource-group rg-device-management
```

## Monitoreo y Debugging

### Ver Logs de las Web Apps

```bash
# Logs del backend
az webapp log tail --name device-backend-app --resource-group rg-device-management

# Logs del frontend
az webapp log tail --name device-frontend-app --resource-group rg-device-management
```

### Abrir SSH en el contenedor

```bash
# Backend
az webapp ssh --name device-backend-app --resource-group rg-device-management

# Frontend
az webapp ssh --name device-frontend-app --resource-group rg-device-management
```

### Ver estado de las aplicaciones

```bash
az webapp list --resource-group rg-device-management --output table
```

## Costos Estimados (Azure for Students)

- **App Service Plan B1**: ~$13 USD/mes (cubierto por créditos)
- **Application Insights**: Primeros 5GB gratis/mes
- **Container Registry Basic**: ~$5 USD/mes
- **Almacenamiento Blob**: Minimal para fotos

**Total estimado**: ~$18 USD/mes (cubierto por tu suscripción de Azure for Students)

## URLs de Acceso

- **Frontend**: https://device-frontend-app.azurewebsites.net
- **Backend API**: https://device-backend-app.azurewebsites.net
- **Application Insights**: https://portal.azure.com (busca "device-management-insights")
- **Axiom**: https://app.axiom.co (una vez configurado)

## Troubleshooting

### La aplicación no inicia
1. Verifica los logs: `az webapp log tail --name device-backend-app --resource-group rg-device-management`
2. Verifica las variables de entorno en el Portal de Azure
3. Asegúrate de que las imágenes se subieron correctamente al ACR

### No veo logs en Application Insights
- Espera 1-2 minutos para que los logs se propaguen
- Verifica que APPLICATIONINSIGHTS_CONNECTION_STRING esté configurado
- Revisa que el código esté importando y usando el logger correctamente

### No veo logs en Axiom
- Verifica que AXIOM_TOKEN y AXIOM_DATASET estén configurados
- Asegúrate de que el token tenga permisos de "Ingest"
- Revisa los logs de la aplicación para ver si hay errores de conexión con Axiom

## Próximos Pasos

1. ✅ Configurar Axiom (proporciona TOKEN y DATASET)
2. Configurar dominio personalizado (opcional)
3. Configurar SSL/TLS certificates
4. Configurar CI/CD con GitHub Actions
5. Configurar alertas en Application Insights
6. Configurar auto-scaling en el App Service Plan
