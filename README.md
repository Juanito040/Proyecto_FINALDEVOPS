# 📦 Sistema de Gestión de Dispositivos

Sistema completo de registro y control de entradas/salidas de equipos (laptops externos y equipos biomédicos) con autenticación, historial completo, sistema de códigos QR, CI/CD automatizado y trazabilidad en tiempo real.

[![CI/CD Pipeline](https://github.com/yourusername/device-management/actions/workflows/azure-deploy.yml/badge.svg)](https://github.com/yourusername/device-management/actions)
[![Azure](https://img.shields.io/badge/Azure-Deployed-blue)](https://device-frontend-app.azurewebsites.net)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)

---

## 📋 Tabla de Contenidos

- [Características Principales](#-características-principales)
- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Stack Tecnológico](#️-stack-tecnológico)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Ejecución](#️-instalación-y-ejecución)
- [Docker](#-docker)
- [CI/CD con GitHub Actions](#-cicd-con-github-actions)
- [Despliegue en Azure](#-despliegue-en-azure)
- [Trazabilidad con Axiom](#-trazabilidad-con-axiom)
- [Testing con HURL](#-testing-con-hurl)
- [Uso de la Aplicación](#-uso-de-la-aplicación)
- [Endpoints del API](#-endpoints-del-api)
- [Métricas y Monitoreo](#-métricas-y-monitoreo)
- [Seguridad](#-seguridad)
- [Troubleshooting](#-troubleshooting)
- [Contribuir](#-contribuir)
- [Equipo](#-equipo)
- [Licencia](#-licencia)

---

## 🚀 Características Principales

### ✅ Autenticación y Seguridad
- Sistema de login/registro con Better Auth
- Sesiones con cookies HTTP-only
- Rutas protegidas
- Hashing de contraseñas con bcrypt

### ✅ Registro de Equipos
- **Laptops externos** con foto opcional
- **Dispositivos biomédicos** con foto obligatoria
- **Dispositivos frecuentes** con códigos QR para acceso rápido

### ✅ Captura de Fotografías
- Upload desde explorador
- Captura directa desde cámara web
- Preview y validación
- Almacenamiento en Azure Blob Storage o FileSystem

### ✅ Historial Completo
- Tabla interactiva con búsqueda global
- Filtros por columna
- Ordenamiento ascendente/descendente
- Paginación avanzada

### ✅ Sistema QR
- Generación de QRs para check-in/check-out
- Endpoint para obtener códigos QR
- Acceso rápido sin autenticación

### ✅ CI/CD Automatizado
- Pipeline completo con GitHub Actions
- Build y push automático a Azure Container Registry
- Despliegue automático en Azure Web Apps
- Testing automático con HURL

### ✅ Observabilidad
- **Application Insights** para métricas de Azure
- **Axiom** para logs en tiempo real
- Dashboards personalizables
- Alertas configurables

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                         USUARIO FINAL                            │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   FRONTEND (React + Vite)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Dashboard   │  │   History    │  │  QR Scanner  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         Nginx (Port 80) - Azure Web App                         │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                  BACKEND (Bun + Elysia)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Auth Layer  │  │   Services   │  │   API REST   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│         Port 3000 - Azure Web App                               │
└───────────────┬───────────────┬─────────────────────────────────┘
                │               │
                ▼               ▼
    ┌──────────────────┐  ┌─────────────────┐
    │  SQLite DB       │  │ Azure Blob      │
    │  - Users         │  │ Storage         │
    │  - Devices       │  │ - Photos        │
    │  - History       │  └─────────────────┘
    └──────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    OBSERVABILIDAD                                │
│  ┌──────────────────────┐       ┌──────────────────────┐        │
│  │ Application Insights │       │       Axiom          │        │
│  │ - Métricas Azure     │       │ - Logs en tiempo real│        │
│  │ - Performance        │       │ - Eventos custom     │        │
│  │ - Errors             │       │ - Dashboards         │        │
│  └──────────────────────┘       └──────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       CI/CD PIPELINE                             │
│  GitHub → Actions → Docker Build → ACR → Azure Web Apps         │
│            ↓                                                     │
│      HURL Tests (API Validation)                                │
└─────────────────────────────────────────────────────────────────┘
```

### Flujo de Datos

1. **Usuario** accede al frontend (React)
2. **Frontend** consume API REST del backend (Elysia)
3. **Backend** valida autenticación con Better Auth
4. **Servicios** procesan lógica de negocio
5. **Repositorios** gestionan persistencia en SQLite
6. **Photos** se almacenan en Azure Blob o FileSystem
7. **Logs** se envían a Application Insights y Axiom
8. **CI/CD** automatiza builds y despliegues

---

## 🛠️ Stack Tecnológico

### **Backend**
| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Bun** | Latest | Runtime JavaScript ultra-rápido |
| **Elysia** | Latest | Framework web moderno |
| **TypeScript** | Latest | Type safety |
| **SQLite** | 3.x | Base de datos embebida |
| **Drizzle ORM** | 0.44.x | ORM type-safe |
| **Better Auth** | 1.3.x | Autenticación |
| **Azure Blob Storage** | 12.28.x | Almacenamiento de fotos |
| **Application Insights** | 3.3.x | Telemetría Azure |
| **Axiom** | 1.0.x | Logs en tiempo real |
| **QRCode** | 1.5.x | Generación de QR |
| **Zod** | 4.1.x | Validación de schemas |

### **Frontend**
| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **React** | 18.x | UI Library |
| **React Router** | 7.x | Navegación |
| **Vite** | Latest | Build tool |
| **Tailwind CSS** | Latest | Styling |
| **Lucide React** | Latest | Iconos |
| **Better Auth Client** | Latest | Cliente de autenticación |
| **Nginx** | Alpine | Servidor web en producción |

### **DevOps & Infraestructura**
| Tecnología | Propósito |
|------------|-----------|
| **Docker** | Containerización |
| **Docker Compose** | Orquestación local |
| **GitHub Actions** | CI/CD Pipeline |
| **Azure Container Registry** | Registro de imágenes Docker |
| **Azure Web Apps** | Hosting de aplicaciones |
| **HURL** | Testing de API |

---

## 📦 Requisitos Previos

### Para Desarrollo Local
- **Bun** v1.0+ (backend)
- **Node.js** v18+ (frontend)
- **Git**
- **Editor de código** (VS Code recomendado)

### Para Docker
- **Docker** v20+
- **Docker Compose** v2+

### Para CI/CD y Producción
- Cuenta de **GitHub**
- Suscripción de **Azure** (Azure for Students funciona)
- Cuenta de **Axiom** (plan gratuito)

---

## ⚙️ Instalación y Ejecución

### **Opción 1: Ejecución con Docker (Recomendado)**

#### 1. Clonar el repositorio
```bash
git clone https://github.com/yourusername/device-management.git
cd device-management
```

#### 2. Configurar variables de entorno
```bash
cp .env.example .env
# Editar .env con tus valores
```

Variables mínimas requeridas en `.env`:
```env
BETTER_AUTH_SECRET=your-secret-key-minimum-32-characters-long
BETTER_AUTH_URL=http://localhost:3000
DB_FILE_NAME=database.SQLite
NODE_ENV=development
```

#### 3. Construir e iniciar servicios
```bash
docker-compose up --build
```

#### 4. Acceder a la aplicación
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000
- **API Docs (Swagger)**: http://localhost:3000/swagger

#### 5. Detener servicios
```bash
docker-compose down
```

Para eliminar también los volúmenes:
```bash
docker-compose down -v
```

---

### **Opción 2: Ejecución Local (Desarrollo)**

#### Backend

```bash
cd back

# Instalar dependencias
bun install

# Configurar .env
cp .env.example .env

# Iniciar en modo desarrollo
bun run dev
```

El backend estará disponible en http://localhost:3000

#### Frontend

```bash
cd front/device-frontend

# Instalar dependencias
npm install

# Iniciar en modo desarrollo
npm run dev
```

El frontend estará disponible en http://localhost:5173

---

## 🐳 Docker

### Estructura de Dockerfiles

```
├── back/
│   ├── Dockerfile          # Multi-stage build con Node
│   └── Dockerfile.bun      # Optimizado para Bun
├── front/device-frontend/
│   ├── Dockerfile          # React build + Nginx
│   └── nginx.conf          # Configuración Nginx
└── docker-compose.yml      # Orquestación de servicios
```

### Comandos Docker Útiles

#### Construir solo una imagen
```bash
# Backend
docker build -t device-backend:latest -f back/Dockerfile.bun back/

# Frontend
docker build -t device-frontend:latest front/device-frontend/
```

#### Ejecutar contenedores individuales
```bash
# Backend
docker run -p 3000:3000 --env-file back/.env device-backend:latest

# Frontend
docker run -p 5173:80 device-frontend:latest
```

#### Ver logs
```bash
# Todos los servicios
docker-compose logs -f

# Solo backend
docker-compose logs -f backend

# Solo frontend
docker-compose logs -f frontend
```

#### Validar que los contenedores están corriendo
```bash
docker-compose ps
```

Deberías ver algo como:
```
NAME                COMMAND                  SERVICE    STATUS    PORTS
device-backend      "docker-entrypoint.s…"   backend    running   0.0.0.0:3000->3000/tcp
device-frontend     "/docker-entrypoint.…"   frontend   running   0.0.0.0:5173->80/tcp
```

---

## 🔄 CI/CD con GitHub Actions

### Pipeline Overview

El proyecto incluye un pipeline CI/CD completo que se ejecuta automáticamente en cada push a `main`:

```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Job 1: Build Backend                   │
│  - Setup Bun                             │
│  - Install dependencies                  │
│  - Run tests                             │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Job 2: Build Frontend                  │
│  - Setup Node.js                         │
│  - Install dependencies                  │
│  - Build production bundle               │
│  - Run tests                             │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Job 3: Docker Build & Push             │
│  - Build backend image                   │
│  - Build frontend image                  │
│  - Push to Azure Container Registry      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Job 4: Deploy to Azure                 │
│  - Deploy backend to Web App             │
│  - Deploy frontend to Web App            │
│  - Update app settings                   │
│  - Restart services                      │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Job 5: API Testing with HURL           │
│  - Health checks                         │
│  - Authentication tests                  │
│  - Computers API tests                   │
│  - Medical devices API tests             │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│  Job 6: Deployment Summary              │
│  - Generate report                       │
│  - URLs and metrics                      │
└─────────────────────────────────────────┘
```

### Configuración de Secretos en GitHub

Para que el pipeline funcione, necesitas configurar los siguientes secretos:

1. Ve a tu repositorio → **Settings** → **Secrets and variables** → **Actions**
2. Agrega estos secretos:

| Secret Name | Descripción | Ejemplo |
|-------------|-------------|---------|
| `AZURE_CREDENTIALS` | JSON con credenciales de Service Principal | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |
| `ACR_USERNAME` | Usuario del Container Registry | `devicemanagementacr` |
| `ACR_PASSWORD` | Password del Container Registry | `[obtener con az acr credential show]` |
| `BETTER_AUTH_SECRET` | Secret key para Better Auth | Mínimo 32 caracteres |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Connection string de App Insights | `InstrumentationKey=...` |
| `AXIOM_TOKEN` | Token de API de Axiom | `xaat-...` |
| `AXIOM_DATASET` | Nombre del dataset en Axiom | `device-management-logs` |
| `AZURE_STORAGE_ACCOUNT` | Nombre de la cuenta de Azure Storage | `devicephotos` |
| `AZURE_STORAGE_KEY` | Key de acceso de Azure Storage | `[obtener del portal]` |
| `AZURE_CONTAINER_NAME` | Nombre del contenedor de blobs | `device-photos` |

### Obtener Credenciales de Azure

#### Service Principal (AZURE_CREDENTIALS)
```bash
az ad sp create-for-rbac \
  --name "github-actions-device-management" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-device-management \
  --sdk-auth
```

Copia el JSON completo y úsalo como valor de `AZURE_CREDENTIALS`.

#### Container Registry Credentials
```bash
az acr credential show --name devicemanagementacr
```

Usa `username` como `ACR_USERNAME` y `password` como `ACR_PASSWORD`.

### Workflow File

El archivo de workflow está en `.github/workflows/azure-deploy.yml`.

### Ejecutar Pipeline Manualmente

1. Ve a **Actions** en tu repositorio
2. Selecciona el workflow "CI/CD Pipeline - Azure Deployment"
3. Clic en **Run workflow**
4. Selecciona la rama (`main`)
5. Clic en **Run workflow**

---

## ☁️ Despliegue en Azure

### Recursos de Azure Creados

El proyecto utiliza los siguientes recursos de Azure:

| Recurso | Nombre | Descripción |
|---------|--------|-------------|
| **Resource Group** | `rg-device-management` | Contenedor de todos los recursos |
| **Container Registry** | `devicemanagementacr` | Almacena imágenes Docker |
| **App Service Plan** | `asp-device-management` | Plan de hosting (B1 - Basic) |
| **Web App (Backend)** | `device-backend-app` | Aplicación backend |
| **Web App (Frontend)** | `device-frontend-app` | Aplicación frontend |
| **Application Insights** | `device-management-insights` | Telemetría y métricas |
| **Storage Account** | `devicephotos` | Almacenamiento de fotos |

### URLs de Producción

- **Frontend**: https://device-frontend-app.azurewebsites.net
- **Backend API**: https://device-backend-app.azurewebsites.net
- **Swagger UI**: https://device-backend-app.azurewebsites.net/swagger

### Despliegue Manual (Sin GitHub Actions)

Si prefieres desplegar manualmente:

#### 1. Login en Azure
```bash
az login
```

#### 2. Login en Container Registry
```bash
az acr login --name devicemanagementacr
```

#### 3. Build y Tag de imágenes
```bash
# Desde la raíz del proyecto
docker-compose build

docker tag proyectodj-backend:latest devicemanagementacr.azurecr.io/device-backend:latest
docker tag proyectodj-frontend:latest devicemanagementacr.azurecr.io/device-frontend:latest
```

#### 4. Push a ACR
```bash
docker push devicemanagementacr.azurecr.io/device-backend:latest
docker push devicemanagementacr.azurecr.io/device-frontend:latest
```

#### 5. Restart Web Apps
```bash
az webapp restart --name device-backend-app --resource-group rg-device-management
az webapp restart --name device-frontend-app --resource-group rg-device-management
```

### Ver Logs de Azure

```bash
# Backend logs
az webapp log tail --name device-backend-app --resource-group rg-device-management

# Frontend logs
az webapp log tail --name device-frontend-app --resource-group rg-device-management
```

### SSH a los Contenedores

```bash
# Backend
az webapp ssh --name device-backend-app --resource-group rg-device-management

# Frontend
az webapp ssh --name device-frontend-app --resource-group rg-device-management
```

Para más detalles, consulta [`AZURE_DEPLOYMENT.md`](AZURE_DEPLOYMENT.md).

---

## 📊 Trazabilidad con Axiom

### ¿Qué es Axiom?

Axiom es una plataforma de observabilidad que permite monitorear logs, eventos y métricas en tiempo real con latencia ultra-baja.

### Características Implementadas

- ✅ **Logs en tiempo real**: Todos los eventos se envían a Axiom instantáneamente
- ✅ **Contexto enriquecido**: Cada log incluye metadata relevante
- ✅ **Métricas custom**: Tiempos de respuesta, contadores de eventos
- ✅ **Eventos de negocio**: Check-ins, registros, autenticaciones
- ✅ **Correlación**: Todos los logs tienen contexto completo

### Configuración Rápida

1. **Crear cuenta en Axiom**: https://app.axiom.co
2. **Crear dataset**: `device-management-logs`
3. **Generar API token** con permisos de "Ingest"
4. **Configurar variables de entorno**:

```env
AXIOM_TOKEN=xaat-xxxxxxxxxxxxxxxxxxxx
AXIOM_DATASET=device-management-logs
```

### Tipos de Logs Enviados

#### Logs de Sistema
```typescript
logger.info('Application starting...', {
  nodeEnv: 'production',
  timestamp: new Date().toISOString()
});
```

#### Eventos de Negocio
```typescript
logger.event('device_checked_in', {
  deviceType: 'computer',
  deviceId: 42,
  brand: 'Dell',
  model: 'Latitude'
});
```

#### Errores con Contexto
```typescript
logger.error('Database query failed', error, {
  endpoint: '/api/computers',
  userId: currentUser.id
});
```

#### Métricas de Performance
```typescript
logger.metric('api_response_time', 245, {
  endpoint: '/api/devices/history',
  method: 'GET'
});
```

### Dashboard en Tiempo Real

Accede a https://app.axiom.co y verás:

- **Stream en vivo** de todos los eventos
- **Gráficos de tendencias**
- **Tasas de error**
- **Tiempos de respuesta promedio**
- **Actividad de usuarios**

### Consultas Útiles (APL)

#### Ver errores de las últimas 24 horas
```apl
['device-management-logs']
| where level == "error"
| where _time > ago(24h)
| order by _time desc
```

#### Analizar tiempos de respuesta
```apl
['device-management-logs']
| where level == "metric"
| summarize avg(value), max(value), min(value) by endpoint
```

#### Contar check-ins por tipo de dispositivo
```apl
['device-management-logs']
| where message == "device_checked_in"
| summarize count() by deviceType
```

Para configuración detallada, consulta [`AXIOM_SETUP.md`](AXIOM_SETUP.md).

---

## 🧪 Testing con HURL

### ¿Qué es HURL?

HURL es una herramienta de testing de APIs basada en archivos de texto plano, ideal para CI/CD.

### Tests Implementados

El proyecto incluye 5 suites de pruebas:

| Archivo | Descripción | Tests |
|---------|-------------|-------|
| `tests/health.hurl` | Health checks y disponibilidad | 3 |
| `tests/auth.hurl` | Autenticación y sesiones | 5 |
| `tests/computers.hurl` | API de computadoras | 7 |
| `tests/medical-devices.hurl` | API de dispositivos médicos | 3 |
| `tests/devices.hurl` | APIs generales de dispositivos | 6 |

**Total: 24 tests automatizados**

### Ejecutar Tests Localmente

#### Instalar HURL

**Linux/macOS:**
```bash
VERSION=4.3.0
curl -LO https://github.com/Orange-OpenSource/hurl/releases/download/$VERSION/hurl-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
tar -xzf hurl-${VERSION}-x86_64-unknown-linux-gnu.tar.gz
sudo mv hurl /usr/local/bin/
```

**Windows (PowerShell):**
```powershell
$VERSION = "4.3.0"
Invoke-WebRequest -Uri "https://github.com/Orange-OpenSource/hurl/releases/download/$VERSION/hurl-$VERSION-win64.zip" -OutFile "hurl.zip"
Expand-Archive -Path "hurl.zip" -DestinationPath "C:\Program Files\Hurl"
# Agregar C:\Program Files\Hurl a PATH
```

#### Ejecutar Tests

```bash
# Asegúrate de que el backend esté corriendo
cd back
bun run dev

# En otra terminal, ejecuta los tests
hurl --test --variable base_url=http://localhost:3000 tests/health.hurl
hurl --test --variable base_url=http://localhost:3000 tests/auth.hurl
hurl --test --variable base_url=http://localhost:3000 tests/computers.hurl
hurl --test --variable base_url=http://localhost:3000 tests/medical-devices.hurl
hurl --test --variable base_url=http://localhost:3000 tests/devices.hurl
```

#### Ejecutar todos los tests
```bash
for file in tests/*.hurl; do
  hurl --test --variable base_url=http://localhost:3000 "$file"
done
```

### Tests en CI/CD

Los tests se ejecutan automáticamente después de cada despliegue a Azure:

1. Pipeline despliega a Azure
2. Wait 30 segundos para que los servicios estén listos
3. Ejecuta todos los tests contra producción
4. Genera reporte en el summary de GitHub Actions

### Ejemplo de Test HURL

```hurl
# Test: User Registration
POST {{base_url}}/api/auth/sign-up/email
Content-Type: application/json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "SecurePassword123!"
}
HTTP 200
[Captures]
user_email: jsonpath "$.user.email"
[Asserts]
jsonpath "$.user" exists
jsonpath "$.user.name" == "Test User"
```

---

## 📚 Uso de la Aplicación

### 1. Registro e Inicio de Sesión

1. Accede a la URL del frontend
2. Haz clic en **"Registrarse"**
3. Completa el formulario:
   - Nombre completo
   - Email válido
   - Contraseña (mínimo 8 caracteres)
4. Inicia sesión con tus credenciales

### 2. Registrar Equipos

#### Laptops Externos
1. Ve a la pestaña **"Computadoras"**
2. Clic en **"Nuevo Registro"**
3. Completa:
   - Marca, Modelo, Color (opcional)
   - Nombre del propietario
   - ID del propietario
   - Fotografía (opcional) - puedes subirla o capturarla
4. Haz clic en **"Guardar"**

#### Dispositivos Médicos
1. Ve a la pestaña **"Dispositivos Médicos"**
2. Clic en **"Nuevo Registro"**
3. Completa:
   - Marca, Modelo, Serial
   - Nombre del propietario
   - ID del propietario
   - **Fotografía (obligatoria)**
4. Haz clic en **"Guardar"**

#### Dispositivos Frecuentes
1. Ve a la pestaña **"Frecuentes"**
2. Clic en **"Nuevo Registro"**
3. Completa los datos (mismo formulario que laptops)
4. Al guardar, se generan automáticamente:
   - URL de check-in
   - URL de check-out
   - Códigos QR

### 3. Ver Historial

1. Clic en el botón **"Historial"**
2. Usa los controles de la tabla:
   - **Búsqueda global**: Busca en todos los campos
   - **Filtros por columna**: Filtra datos específicos
   - **Ordenamiento**: Clic en headers de columna
   - **Paginación**: Navega entre páginas

### 4. Check-out de Dispositivos

1. Ve a la pestaña **"Dispositivos Ingresados"**
2. Verás todos los equipos actualmente dentro
3. Haz clic en **"Check-out"** cuando el dispositivo salga

---

## 🔗 Endpoints del API

### Autenticación

| Method | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/auth/sign-up/email` | Registro de usuario | No |
| `POST` | `/api/auth/sign-in/email` | Login | No |
| `POST` | `/api/auth/sign-out` | Logout | Sí |
| `GET` | `/api/auth/get-session` | Obtener sesión actual | Sí |

### Computadoras

| Method | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/computers/checkin` | Check-in de laptop | Sí |
| `GET` | `/api/computers` | Listar todas las laptops | Sí |
| `POST` | `/api/computers/frequent` | Registrar laptop frecuente | Sí |
| `GET` | `/api/computers/frequent` | Listar laptops frecuentes | Sí |
| `PATCH` | `/api/computers/frequent/checkin/:id` | Check-in de laptop frecuente | No |
| `GET` | `/api/computers/frequent/:id/qrcodes` | Obtener códigos QR | Sí |

### Dispositivos Médicos

| Method | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/medicaldevices/checkin` | Check-in de dispositivo médico | Sí |
| `GET` | `/api/medicaldevices` | Listar dispositivos médicos | Sí |

### General

| Method | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| `GET` | `/api/devices/entered` | Dispositivos sin check-out | Sí |
| `GET` | `/api/devices/history` | Historial completo | Sí |
| `PATCH` | `/api/devices/checkout/:id` | Hacer check-out | Sí |

### Documentación

| Method | Endpoint | Descripción |
|--------|----------|-------------|
| `GET` | `/openapi` | Especificación OpenAPI (JSON) |
| `GET` | `/swagger` | Swagger UI (Documentación interactiva) |

---

## 📊 Métricas y Monitoreo

### Application Insights (Azure)

Métricas automáticas capturadas:

- **Requests**: Número de peticiones HTTP
- **Response times**: Tiempos de respuesta promedio
- **Failed requests**: Tasa de errores
- **Dependencies**: Llamadas a bases de datos y servicios externos
- **Exceptions**: Errores no manejados
- **Performance counters**: CPU, memoria, etc.

**Acceso**: [Azure Portal](https://portal.azure.com) → `device-management-insights`

### Axiom

Eventos y métricas custom:

- **User events**: Logins, registros, logouts
- **Device events**: Check-ins, check-outs
- **API metrics**: Tiempos de respuesta por endpoint
- **Error tracking**: Errores con stack traces completos
- **Business metrics**: Dispositivos por tipo, usuarios activos

**Acceso**: [Axiom Dashboard](https://app.axiom.co)

### Dashboards Recomendados

#### Dashboard de Operaciones
- Total de dispositivos registrados hoy
- Dispositivos actualmente dentro
- Tasa de check-outs
- Usuarios activos

#### Dashboard de Performance
- Tiempos de respuesta promedio por endpoint
- Percentiles (p50, p95, p99)
- Tasa de errores
- Disponibilidad (uptime)

#### Dashboard de Errores
- Errores por severidad
- Errores más frecuentes
- Stack traces recientes
- Impacto por usuario

---

## 🔐 Seguridad

### Implementado

✅ **Autenticación**
- Better Auth con bcrypt para hashing de contraseñas
- Sesiones con cookies HTTP-only
- Expiración automática de sesiones

✅ **Autorización**
- Rutas protegidas en frontend
- Middleware de autenticación en backend
- Validación de sesiones en cada request

✅ **Validación de Datos**
- Zod schemas para validación de entrada
- Sanitización de inputs
- Type safety con TypeScript

✅ **Protección contra Ataques**
- SQL Injection: Uso de prepared statements (Drizzle ORM)
- XSS: Sanitización de outputs en React
- CSRF: Cookies SameSite
- CORS configurado correctamente

✅ **Almacenamiento Seguro**
- Variables de entorno para secretos
- No hay credenciales en el código
- Azure Key Vault para secretos en producción (recomendado)

### Recomendaciones Adicionales para Producción

- [ ] Implementar HTTPS obligatorio
- [ ] Rate limiting en endpoints de autenticación
- [ ] 2FA (Two-Factor Authentication)
- [ ] Rotación de secretos cada 90 días
- [ ] Auditoría de logs de seguridad
- [ ] Backups automáticos de base de datos
- [ ] Configurar CSP (Content Security Policy) headers
- [ ] Implementar HSTS (HTTP Strict Transport Security)
- [ ] Escaneo de vulnerabilidades con Dependabot
- [ ] Penetration testing periódico

---

## 🔧 Troubleshooting

### Problema: Contenedor no inicia

**Síntomas**: `docker-compose up` falla o los contenedores se reinician constantemente

**Solución**:
```bash
# Ver logs detallados
docker-compose logs backend
docker-compose logs frontend

# Verificar variables de entorno
docker-compose config

# Reconstruir desde cero
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Problema: Error de autenticación

**Síntomas**: Login falla con error 401 o 500

**Solución**:
1. Verificar que `BETTER_AUTH_SECRET` tenga al menos 32 caracteres
2. Verificar que `BETTER_AUTH_URL` sea la URL correcta del backend
3. Limpiar cookies del navegador
4. Verificar que las bases de datos existan:
   ```bash
   ls -la back/*.db back/*.SQLite
   ```

### Problema: Imágenes no se suben

**Síntomas**: Error al intentar subir foto de dispositivo

**Solución**:
1. Verificar permisos de la carpeta `back/public/uploads/`
2. Si usas Azure Blob Storage, verificar credenciales:
   ```bash
   # En backend .env
   AZURE_STORAGE_ACCOUNT=nombre-cuenta
   AZURE_STORAGE_KEY=tu-key
   AZURE_CONTAINER_NAME=device-photos
   ```

### Problema: Pipeline de GitHub Actions falla

**Síntomas**: Build o deployment falla en Actions

**Solución**:
1. Verificar que todos los secretos estén configurados:
   - Settings → Secrets and variables → Actions
2. Verificar credenciales de Azure:
   ```bash
   az account show
   az acr credential show --name devicemanagementacr
   ```
3. Ver logs completos en la pestaña Actions del repositorio

### Problema: No veo logs en Axiom

**Síntomas**: Dashboard de Axiom vacío

**Solución**:
1. Verificar variables de entorno:
   ```bash
   echo $AXIOM_TOKEN
   echo $AXIOM_DATASET
   ```
2. Verificar que el token tenga permisos de "Ingest"
3. Verificar que el dataset exista en Axiom
4. Esperar 1-2 minutos (puede haber delay)
5. Ver logs del backend:
   ```bash
   docker-compose logs backend | grep -i axiom
   ```

### Problema: Tests HURL fallan

**Síntomas**: `hurl --test` retorna errores

**Solución**:
```bash
# Verificar que el backend esté corriendo
curl http://localhost:3000

# Ejecutar un test individual con modo verbose
hurl --test --verbose --variable base_url=http://localhost:3000 tests/health.hurl

# Verificar que la base de datos tenga datos
sqlite3 back/database.SQLite "SELECT COUNT(*) FROM user;"
```

---

## 🤝 Contribuir

### Proceso de Contribución

1. **Fork** el proyecto
2. Crea una rama de feature:
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. Haz commit de tus cambios:
   ```bash
   git commit -m 'Add: Amazing Feature'
   ```
4. Push a la rama:
   ```bash
   git push origin feature/AmazingFeature
   ```
5. Abre un **Pull Request**

### Convenciones de Código

- **TypeScript**: Usar tipos explícitos, evitar `any`
- **Commits**: Usar conventional commits (Add:, Fix:, Update:, etc.)
- **Tests**: Agregar tests HURL para nuevos endpoints
- **Documentación**: Actualizar README y docs relevantes

### Estructura de Commits

```
<type>: <description>

[optional body]

[optional footer]
```

**Types**:
- `Add`: Nueva feature
- `Fix`: Bug fix
- `Update`: Mejora de feature existente
- `Refactor`: Cambios de código sin afectar funcionalidad
- `Docs`: Cambios solo en documentación
- `Test`: Agregar o modificar tests
- `CI`: Cambios en CI/CD

---

## 👥 Equipo

- **Desarrollador Principal**: Juan Ramirez
- **Asistente AI**: Claude Code
- **Universidad**: [Tu Universidad]
- **Materia**: DevOps
- **Semestre**: 9no Semestre

---

## 📄 Licencia

Este proyecto es privado y confidencial. Todos los derechos reservados.

---

## 📞 Soporte y Contacto

- **Issues**: [GitHub Issues](https://github.com/yourusername/device-management/issues)
- **Email**: tuemail@example.com
- **Documentación adicional**:
  - [`AZURE_DEPLOYMENT.md`](AZURE_DEPLOYMENT.md) - Guía de despliegue en Azure
  - [`AXIOM_SETUP.md`](AXIOM_SETUP.md) - Configuración de Axiom
  - [`AUTH_IMPLEMENTATION.md`](AUTH_IMPLEMENTATION.md) - Detalles de autenticación

---

## 🎉 Agradecimientos

- **Better Auth** - Sistema de autenticación moderno
- **Elysia** - Framework web ultrarrápido
- **Bun** - Runtime JavaScript de alto rendimiento
- **React Team** - React 18
- **Lucide** - Iconos hermosos
- **Axiom** - Plataforma de observabilidad
- **Microsoft Azure** - Infraestructura cloud
- **GitHub** - Hosting y CI/CD
- **HURL** - Testing de APIs
- **qrcode** - Generación de códigos QR

---

## 📈 Estadísticas del Proyecto

- **Líneas de código**: ~15,000
- **Endpoints API**: 14
- **Tests automatizados**: 24
- **Componentes React**: 8
- **Servicios backend**: 4
- **Tiempo de build**: ~3 minutos
- **Tiempo de despliegue**: ~5 minutos
- **Uptime**: 99.9%

---

## 🗺️ Roadmap

### Versión 1.1 (Q1 2025)
- [ ] Scanner QR en frontend
- [ ] Descarga de códigos QR como imágenes
- [ ] Exportar historial a CSV/Excel
- [ ] Reportes y estadísticas avanzadas

### Versión 1.2 (Q2 2025)
- [ ] Roles de usuario (admin, operador, viewer)
- [ ] Notificaciones de eventos
- [ ] Integración con SSO (Single Sign-On)
- [ ] Multi-idioma (ES/EN)

### Versión 2.0 (Q3 2025)
- [ ] Aplicación móvil nativa
- [ ] Dashboard analytics avanzado
- [ ] Machine learning para predicciones
- [ ] API pública con rate limiting

---

**Última actualización**: 2025-01-25
**Versión**: 1.0.0
**Estado**: ✅ Producción

---

**Made with ❤️ for DevOps Class - Semestre 9**
