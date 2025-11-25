# 🚀 Guía Completa: Despliegue en Azure desde Cero

## ✅ Completado Hasta Ahora

### 1. Login en Azure ✅
```bash
az login
```
- ✅ Logueado con cuenta: daniel.ramirezm@usantoto.edu.co
- ✅ Suscripción: Azure for Students

### 2. Recursos Creados en Azure ✅

Todos estos recursos YA EXISTÍAN de sesiones anteriores:

- ✅ **Resource Group**: `rg-device-management` (East US 2)
- ✅ **Container Registry**: `devicemanagementacr` (Login Server: devicemanagementacr.azurecr.io)
- ✅ **Application Insights**: `device-management-insights`
- ✅ **App Service Plan**: `asp-device-management` (SKU: B1 Linux)
- ✅ **Web App Backend**: `device-backend-app` (https://device-backend-app.azurewebsites.net)
- ✅ **Web App Frontend**: `device-frontend-app` (https://device-frontend-app.azurewebsites.net)

### 3. Build de Imágenes Docker ✅
```bash
# Regenerar lockfile de Bun
cd back
bun install
cd ..

# Build con docker-compose
docker-compose build --no-cache
```
- ✅ Backend build exitoso (imagen: 666MB)
- ✅ Frontend build exitoso (imagen: 80.2MB)

### 4. Push a Azure Container Registry ⏳ EN PROGRESO
```bash
# Tag de imágenes
docker tag proyecto_finaldevops-backend:latest devicemanagementacr.azurecr.io/device-backend:latest
docker tag proyecto_finaldevops-frontend:latest devicemanagementacr.azurecr.io/device-frontend:latest

# Push a ACR
docker push devicemanagementacr.azurecr.io/device-backend:latest
docker push devicemanagementacr.azurecr.io/device-frontend:latest
```

---

## 📝 Próximos Pasos (Después del Push)

### 5. Reiniciar Web Apps en Azure
```bash
# Restart backend
az webapp restart \
  --name device-backend-app \
  --resource-group rg-device-management

# Restart frontend
az webapp restart \
  --name device-frontend-app \
  --resource-group rg-device-management
```

### 6. Obtener Credenciales para GitHub Secrets

#### Application Insights Connection String
```bash
az monitor app-insights component show \
  --app device-management-insights \
  --resource-group rg-device-management \
  --query connectionString \
  --output tsv
```

#### Azure Container Registry Credentials
```bash
az acr credential show --name devicemanagementacr
```
Esto te dará:
- `ACR_USERNAME`
- `ACR_PASSWORD` (usar password)

#### Service Principal para GitHub Actions
```bash
az ad sp create-for-rbac \
  --name "github-actions-device-management" \
  --role contributor \
  --scopes /subscriptions/1664afe0-9130-4c1f-a701-93b9d0b1b789/resourceGroups/rg-device-management \
  --sdk-auth
```
Esto te dará el JSON completo para `AZURE_CREDENTIALS`.

---

## 🔐 Secretos para GitHub Actions

Ve a tu repositorio de GitHub:
**Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Agrega los siguientes secretos:

### Secretos Requeridos

| Secret Name | Cómo Obtenerlo | Ejemplo |
|-------------|----------------|---------|
| `AZURE_CREDENTIALS` | `az ad sp create-for-rbac ...` (ver arriba) | JSON completo |
| `ACR_USERNAME` | `az acr credential show ...` | `devicemanagementacr` |
| `ACR_PASSWORD` | `az acr credential show ...` | (password de ACR) |
| `BETTER_AUTH_SECRET` | Generar string de 32+ chars | `supersecretkey1234567890abcdefgh` |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | `az monitor app-insights ...` | `InstrumentationKey=...` |
| `AXIOM_TOKEN` | Desde https://app.axiom.co | `xaat-xxxxx...` |
| `AXIOM_DATASET` | Nombre del dataset en Axiom | `device-management-logs` |
| `AZURE_STORAGE_ACCOUNT` | (opcional) Nombre de storage account | `devicephotos` |
| `AZURE_STORAGE_KEY` | (opcional) Key de storage account | (obtener del portal) |
| `AZURE_CONTAINER_NAME` | (opcional) Nombre del contenedor | `device-photos` |

---

## 🌐 Configuración de Axiom

### Paso 1: Crear Cuenta
1. Ve a https://app.axiom.co
2. Regístrate (gratuito)

### Paso 2: Crear Dataset
1. En Axiom dashboard, clic en **"Datasets"**
2. Clic en **"Create Dataset"**
3. Nombre: `device-management-logs`
4. Descripción: `Logs and events from Device Management System`

### Paso 3: Generar API Token
1. Ve a **Settings** → **API Tokens**
2. Clic en **"Create Token"**
3. Name: `device-management-backend`
4. Permissions: **"Ingest"**
5. Copiar el token generado (`xaat-xxxxx...`)

### Paso 4: Agregar a GitHub Secrets
- `AXIOM_TOKEN`: el token que copiaste
- `AXIOM_DATASET`: `device-management-logs`

---

## ✅ Validación del Despliegue

### 1. Verificar que las Web Apps están corriendo
```bash
# Ver logs del backend
az webapp log tail \
  --name device-backend-app \
  --resource-group rg-device-management

# Ver logs del frontend
az webapp log tail \
  --name device-frontend-app \
  --resource-group rg-device-management
```

### 2. Probar las URLs en el navegador
- **Frontend**: https://device-frontend-app.azurewebsites.net
- **Backend API**: https://device-backend-app.azurewebsites.net
- **Swagger UI**: https://device-backend-app.azurewebsites.net/swagger

### 3. Verificar Application Insights
1. Ve a https://portal.azure.com
2. Busca "device-management-insights"
3. Ve a **Logs** y ejecuta:
```kql
traces
| where timestamp > ago(1h)
| order by timestamp desc
| take 50
```

### 4. Verificar Axiom
1. Ve a https://app.axiom.co
2. Selecciona dataset: `device-management-logs`
3. Deberías ver logs en tiempo real

---

## 🤖 Activar GitHub Actions

### Paso 1: Configurar Secretos
(Ver sección "Secretos para GitHub Actions" arriba)

### Paso 2: Push al Repositorio
```bash
# Agregar todos los cambios
git add .

# Commit
git commit -m "Add: Complete Azure deployment setup with CI/CD pipeline"

# Push a main (esto activará el pipeline)
git push origin main
```

### Paso 3: Monitorear el Pipeline
1. Ve a GitHub → tu repositorio
2. Clic en tab **"Actions"**
3. Verás el workflow "CI/CD Pipeline - Azure Deployment" ejecutándose
4. Clic en el workflow para ver detalles

El pipeline hará:
1. ✅ Build del backend
2. ✅ Build del frontend
3. ✅ Build y push de imágenes Docker a ACR
4. ✅ Deploy a Azure Web Apps
5. ✅ Ejecución de tests HURL
6. ✅ Generación de reporte

---

## 🧪 Testing Manual con HURL

### Instalar HURL (Windows)
```powershell
$VERSION = "4.3.0"
Invoke-WebRequest -Uri "https://github.com/Orange-OpenSource/hurl/releases/download/$VERSION/hurl-$VERSION-win64.zip" -OutFile "hurl.zip"
Expand-Archive -Path "hurl.zip" -DestinationPath "C:\Program Files\Hurl"
# Agregar C:\Program Files\Hurl a PATH
```

### Ejecutar Tests Localmente
```bash
# Health checks
hurl --test --variable base_url=http://localhost:3000 tests/health.hurl

# Tests de autenticación
hurl --test --variable base_url=http://localhost:3000 tests/auth.hurl

# Tests de API de computadoras
hurl --test --variable base_url=http://localhost:3000 tests/computers.hurl

# Tests de dispositivos médicos
hurl --test --variable base_url=http://localhost:3000 tests/medical-devices.hurl

# Tests generales de dispositivos
hurl --test --variable base_url=http://localhost:3000 tests/devices.hurl
```

### Ejecutar Tests contra Producción (Azure)
```bash
hurl --test --variable base_url=https://device-backend-app.azurewebsites.net tests/health.hurl
hurl --test --variable base_url=https://device-backend-app.azurewebsites.net tests/auth.hurl
# etc...
```

---

## 📊 Comandos Útiles

### Ver Estado de Recursos
```bash
# Listar todos los recursos en el resource group
az resource list \
  --resource-group rg-device-management \
  --output table

# Ver detalles de Web App backend
az webapp show \
  --name device-backend-app \
  --resource-group rg-device-management \
  --output table

# Ver detalles de Web App frontend
az webapp show \
  --name device-frontend-app \
  --resource-group rg-device-management \
  --output table
```

### Configurar Variables de Entorno en Azure
```bash
az webapp config appsettings set \
  --name device-backend-app \
  --resource-group rg-device-management \
  --settings \
    BETTER_AUTH_SECRET="your-secret-key-32-chars" \
    BETTER_AUTH_URL="https://device-backend-app.azurewebsites.net" \
    APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=..." \
    AXIOM_TOKEN="xaat-xxxx..." \
    AXIOM_DATASET="device-management-logs" \
    NODE_ENV="production"
```

### SSH a los Contenedores
```bash
# Backend
az webapp ssh \
  --name device-backend-app \
  --resource-group rg-device-management

# Frontend
az webapp ssh \
  --name device-frontend-app \
  --resource-group rg-device-management
```

---

## 🔧 Troubleshooting

### Problema: Web App no inicia
```bash
# Ver logs en tiempo real
az webapp log tail \
  --name device-backend-app \
  --resource-group rg-device-management

# Verificar que la imagen se desplegó
az webapp config container show \
  --name device-backend-app \
  --resource-group rg-device-management
```

### Problema: Pipeline falla en GitHub Actions
1. Verificar que todos los secretos estén configurados
2. Ver logs del pipeline en GitHub Actions
3. Verificar credenciales de Azure:
```bash
az account show
```

### Problema: No veo logs en Axiom
1. Verificar que `AXIOM_TOKEN` y `AXIOM_DATASET` estén configurados en Azure Web App
2. Reiniciar la aplicación
3. Hacer algunas requests al API
4. Esperar 1-2 minutos

---

## 📹 Checklist para el Video

### Parte 1: Recursos en Azure (2 min)
- [ ] Mostrar Azure Portal
- [ ] Mostrar Resource Group `rg-device-management`
- [ ] Mostrar Container Registry con imágenes
- [ ] Mostrar Web Apps corriendo

### Parte 2: Docker (2 min)
- [ ] Mostrar Dockerfiles (backend y frontend)
- [ ] Ejecutar `docker-compose build`
- [ ] Ejecutar `docker-compose up`
- [ ] Mostrar `docker-compose ps`

### Parte 3: GitHub Actions (3 min)
- [ ] Mostrar `.github/workflows/azure-deploy.yml`
- [ ] Mostrar pipeline en GitHub Actions
- [ ] Mostrar logs de cada job
- [ ] Mostrar tests HURL ejecutándose

### Parte 4: Axiom (2 min)
- [ ] Mostrar código del logger
- [ ] Acceder a Axiom dashboard
- [ ] Mostrar logs en tiempo real
- [ ] Ejecutar una consulta APL

### Parte 5: Aplicación Funcionando (2 min)
- [ ] Abrir frontend en navegador
- [ ] Registrar un usuario
- [ ] Registrar un dispositivo
- [ ] Ver historial
- [ ] Mostrar Swagger UI

---

## ✅ Status Actual

- ✅ Azure resources creados
- ✅ Docker images construidas
- ⏳ Push a ACR en progreso
- ⏸️ Pendiente: Configurar secretos en GitHub
- ⏸️ Pendiente: Configurar Axiom
- ⏸️ Pendiente: Validar deployment completo

---

**Última actualización**: 2025-11-25
**Estado**: En progreso - Push a ACR
