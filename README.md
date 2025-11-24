# 📦 Sistema de Gestión de Dispositivos

Sistema completo de registro y control de entradas/salidas de equipos (laptops externos y equipos biomédicos) con autenticación, historial completo y sistema de códigos QR.

---

## 🚀 Características Principales

✅ **Autenticación y Seguridad**
- Sistema de login/registro con Better Auth
- Sesiones con cookies HTTP-only
- Rutas protegidas

✅ **Registro de Equipos**
- Laptops externos con foto opcional
- Dispositivos biomédicos con foto obligatoria
- Dispositivos frecuentes con códigos QR

✅ **Captura de Fotografías**
- Upload desde explorador
- Captura directa desde cámara web
- Preview y validación

✅ **Historial Completo**
- Tabla con búsqueda global
- Filtros por columna
- Ordenamiento ascendente/descendente
- Paginación avanzada

✅ **Sistema QR (Parcial)**
- Generación de QRs para check-in/check-out
- Endpoint para obtener códigos QR

---

## 🛠️ Stack Tecnológico

### **Backend**
- **Runtime:** Bun
- **Framework:** Elysia
- **Lenguaje:** TypeScript
- **Base de Datos:** SQLite
- **ORM:** Drizzle ORM
- **Autenticación:** Better Auth
- **Almacenamiento:** Azure Blob Storage / FileSystem

### **Frontend**
- **Framework:** React 18
- **Router:** React Router v7
- **Build Tool:** Vite
- **Styling:** Tailwind CSS + Custom CSS
- **Iconos:** Lucide React
- **Autenticación:** Better Auth Client

---

## 📁 Estructura del Proyecto

```
ProyectoDJ/
├── Back/                          # Backend (Bun + Elysia)
│   ├── src/
│   │   ├── adapter/              # Capa de adaptadores
│   │   │   ├── api/elysia/      # API REST
│   │   │   ├── photo/           # Repositorio de fotos
│   │   │   └── repository/sql/   # Repositorio SQLite
│   │   ├── core/                # Lógica de negocio
│   │   │   ├── auth/            # Autenticación
│   │   │   ├── domain/          # Modelos de dominio
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   ├── repository/      # Interfaces de repositorio
│   │   │   └── service/         # Servicios de negocio
│   │   └── index.ts
│   ├── Dockerfile.bun           # Dockerfile para Bun
│   ├── package.json
│   └── tsconfig.json
│
├── Front/device-frontend/        # Frontend (React + Vite)
│   ├── src/
│   │   ├── components/          # Componentes React
│   │   │   ├── Dashboard.jsx
│   │   │   ├── Login.jsx
│   │   │   ├── Register.jsx
│   │   │   ├── DeviceHistory.jsx
│   │   │   ├── PhotoCapture.jsx    ✨ NUEVO
│   │   │   ├── DataTable.jsx       ✨ NUEVO
│   │   │   └── ProtectedRoute.jsx
│   │   ├── contexts/
│   │   │   └── AuthContext.jsx
│   │   ├── lib/
│   │   │   └── auth-client.js
│   │   ├── App.jsx
│   │   ├── App.css
│   │   └── main.jsx
│   ├── Dockerfile               # Dockerfile para frontend
│   ├── nginx.conf               # Configuración Nginx
│   ├── package.json
│   └── vite.config.js
│
├── docker-compose.yml           ✨ NUEVO
├── .env.example                 ✨ NUEVO
├── README.md                    ✨ NUEVO
└── MEJORAS_IMPLEMENTADAS.md    ✨ NUEVO
```

---

## ⚙️ Instalación y Ejecución

### **Opción 1: Ejecución con Docker (Recomendado)**

#### Prerrequisitos:
- Docker
- Docker Compose

#### Pasos:

1. **Clonar el repositorio:**
```bash
git clone <repository-url>
cd ProyectoDJ
```

2. **Configurar variables de entorno:**
```bash
cp .env.example .env
# Editar .env con tus valores
```

3. **Construir e iniciar los servicios:**
```bash
docker-compose up --build
```

4. **Acceder a la aplicación:**
- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:3000
- **API Docs:** http://localhost:3000/openapi

5. **Detener los servicios:**
```bash
docker-compose down
```

---

### **Opción 2: Ejecución Local (Desarrollo)**

#### Prerrequisitos:
- Bun v1.0+ (para backend)
- Node.js v18+ (para frontend)

#### Backend:

```bash
cd Back

# Instalar dependencias
bun install

# Configurar .env
cp .env.example .env

# Iniciar en modo desarrollo
bun run dev
```

El backend estará disponible en http://localhost:3000

#### Frontend:

```bash
cd Front/device-frontend

# Instalar dependencias
npm install

# Iniciar en modo desarrollo
npm run dev
```

El frontend estará disponible en http://localhost:5173

---

## 🔑 Variables de Entorno

Consulta el archivo `.env.example` para ver todas las variables disponibles.

### **Variables Obligatorias:**

```env
BETTER_AUTH_SECRET=tu-secret-key-minimo-32-caracteres
BETTER_AUTH_URL=http://localhost:3000
DB_FILE_NAME=db.sqlite
```

### **Variables Opcionales (Azure Blob Storage):**

```env
AZURE_STORAGE_ACCOUNT=nombre-cuenta
AZURE_STORAGE_KEY=clave-acceso
AZURE_CONTAINER_NAME=device-photos
```

---

## 📚 Uso de la Aplicación

### **1. Registro e Inicio de Sesión**

1. Accede a http://localhost:5173
2. Haz clic en "Registrarse"
3. Completa el formulario con:
   - Nombre
   - Email
   - Contraseña (mínimo 8 caracteres)
4. Inicia sesión con tus credenciales

### **2. Registrar Equipos**

#### **Laptops Externos:**
1. Ir a pestaña "Computadoras"
2. Clic en "Nuevo Registro"
3. Completar:
   - Marca, Modelo, Color (opcional)
   - Datos del propietario (Nombre, ID)
   - Fotografía (opcional) - Puedes subirla o capturarla
4. Guardar

#### **Dispositivos Médicos:**
1. Ir a pestaña "Dispositivos Médicos"
2. Clic en "Nuevo Registro"
3. Completar:
   - Marca, Modelo, Serial
   - Datos del propietario
   - Fotografía (obligatoria)
4. Guardar

#### **Dispositivos Frecuentes:**
1. Ir a pestaña "Frecuentes"
2. Clic en "Nuevo Registro"
3. Completar datos (mismo formulario que laptops)
4. Al guardar, se generarán automáticamente:
   - URL de check-in
   - URL de check-out
   - Códigos QR (backend)

### **3. Ver Historial**

1. Clic en botón "Historial"
2. Usar controles de la tabla:
   - **Búsqueda global:** Buscar en todos los campos
   - **Filtros:** Filtrar por columnas específicas
   - **Ordenamiento:** Clic en headers de columna
   - **Paginación:** Navegar entre páginas

### **4. Check-in / Check-out**

1. Ir a pestaña "Dispositivos Ingresados"
2. Ver todos los equipos actualmente dentro
3. Hacer check-out cuando salgan

---

## 🔗 Endpoints del API

### **Autenticación:**
```
POST   /api/auth/sign-up/email    # Registro
POST   /api/auth/sign-in/email    # Login
POST   /api/auth/sign-out         # Logout
GET    /api/auth/get-session      # Obtener sesión
```

### **Computadoras:**
```
POST   /api/computers/checkin                    # Registrar entrada
GET    /api/computers                            # Listar todas
POST   /api/computers/frequent                   # Registrar frecuente
GET    /api/computers/frequent                   # Listar frecuentes
PATCH  /api/computers/frequent/checkin/:id       # Check-in frecuente
GET    /api/computers/frequent/:id/qrcodes       # Obtener QRs ✨ NUEVO
```

### **Dispositivos Médicos:**
```
POST   /api/medicaldevices/checkin   # Registrar entrada
GET    /api/medicaldevices            # Listar todos
```

### **General:**
```
GET    /api/devices/entered    # Dispositivos ingresados (sin checkout)
GET    /api/devices/history    # Historial completo
PATCH  /api/devices/checkout/:id   # Hacer checkout
```

---

## 🧩 Componentes Reutilizables

### **PhotoCapture**

Componente para captura de fotografías con múltiples opciones.

```jsx
import PhotoCapture from './components/PhotoCapture';

<PhotoCapture
  onPhotoSelected={(file) => console.log(file)}
  required={true}
  label="Fotografía"
  maxSizeMB={5}
/>
```

**Props:**
- `onPhotoSelected`: Callback que recibe el File
- `required`: Si es obligatoria
- `label`: Etiqueta del campo
- `maxSizeMB`: Tamaño máximo en MB

### **DataTable**

Tabla con búsqueda, filtros, ordenamiento y paginación.

```jsx
import DataTable from './components/DataTable';

const columns = [
  {
    key: 'name',
    header: 'Nombre',
    sortable: true,
    filterable: true
  },
  {
    key: 'status',
    header: 'Estado',
    render: (value) => <span className={`badge ${value}`}>{value}</span>
  }
];

<DataTable
  data={items}
  columns={columns}
  itemsPerPage={10}
  searchable={true}
  paginated={true}
/>
```

**Props:**
- `data`: Array de datos
- `columns`: Configuración de columnas
- `itemsPerPage`: Elementos por página
- `searchable`: Habilitar búsqueda
- `paginated`: Habilitar paginación
- `emptyMessage`: Mensaje cuando vacío

---

## 🧪 Testing

### **Backend:**
```bash
cd Back
bun test
```

### **Frontend:**
```bash
cd Front/device-frontend
npm test
```

---

## 🐳 Docker

### **Comandos Útiles:**

```bash
# Construir e iniciar
docker-compose up --build

# Iniciar en background
docker-compose up -d

# Ver logs
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f backend

# Detener
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v

# Reiniciar un servicio
docker-compose restart backend
```

### **Estructura de Servicios:**

- **backend**: Puerto 3000
- **frontend**: Puerto 5173 (80 interno)
- **Network**: `device-network` (bridge)
- **Volúmenes**:
  - `backend-photos`: Fotos persistentes
  - Bases de datos SQLite montadas desde host

---

## 📊 Base de Datos

### **Archivos de Base de Datos:**

- `database.SQLite`: Usuarios, sesiones, autenticación
- `devices.db`: Equipos, historial

### **Tablas Principales:**

**Authentication DB:**
- `user`
- `session`
- `account`
- `verification`

**Devices DB:**
- `computers`
- `frequent_computers`
- `medical_devices`
- `device_history`

---

## 🔐 Seguridad

### **Implementado:**
- ✅ Hashing de contraseñas (bcrypt via Better Auth)
- ✅ Cookies HTTP-only
- ✅ Sesiones con expiración
- ✅ CORS configurado
- ✅ Validación con Zod
- ✅ SQL preparado (protección contra SQL injection)

### **Recomendaciones para Producción:**
- [ ] Configurar HTTPS
- [ ] Cambiar `BETTER_AUTH_SECRET` por valor aleatorio
- [ ] Rate limiting en endpoints de auth
- [ ] Configurar CSP headers
- [ ] Auditoría de logs
- [ ] Backup automático de bases de datos

---

## 📝 Próximas Características

### **Alta Prioridad:**
- [ ] Scanner QR en frontend
- [ ] Vista mejorada de dispositivos frecuentes con QRs
- [ ] Endpoint público para registro por QR
- [ ] Descarga de códigos QR

### **Media Prioridad:**
- [ ] Exportar historial a CSV/Excel
- [ ] Reportes y estadísticas
- [ ] Roles de usuario (admin, operador)
- [ ] Notificaciones de eventos

### **Baja Prioridad:**
- [ ] Integración con SSO
- [ ] Multi-idioma
- [ ] Aplicación móvil nativa
- [ ] Dashboard analytics

---

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: Amazing Feature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto es privado y confidencial.

---

## 👥 Equipo

- **Desarrollador Principal:** [Tu Nombre]
- **Asistente AI:** Claude Code

---

## 📞 Soporte

Para reportar bugs o solicitar features, abre un issue en el repositorio.

---

## 🎉 Agradecimientos

- **Better Auth** por el sistema de autenticación
- **Elysia** por el framework backend
- **Bun** por el runtime rápido
- **React Team** por React 18
- **Lucide** por los iconos
- **qrcode** por generación de QRs

---

**Última actualización:** 2025-01-20
**Versión:** 1.0.0
