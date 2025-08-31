# 🚀 Rails BaaS - Backend as a Service

Un **Backend as a Service (BaaS)** completo construido con Ruby on Rails que proporciona autenticación JWT, OAuth con Google, panel de administración y una API REST moderna.

## ✨ Características

- 🔐 **Autenticación JWT** - Login/registro con email y contraseña
- 🔑 **Google OAuth** - Autenticación social con Google
- 👑 **Panel de Administración** - ActiveAdmin para gestión de usuarios
- 🌐 **API REST** - Endpoints completos con documentación
- 📚 **Swagger/OpenAPI** - Documentación interactiva de la API
- 🎨 **Diseño Moderno** - ActiveAdmin con gradientes y animaciones
- 🛡️ **Seguridad** - Validaciones, CORS, y manejo de errores
- 📊 **Dashboard** - Estadísticas y monitoreo en tiempo real
- 🏗️ **Arquitectura escalable** - Servicios modulares y bien estructurados

## 🛠️ Tecnologías Utilizadas

- **Ruby on Rails 7.2** - Framework principal
- **JWT** - Autenticación con tokens
- **ActiveAdmin** - Panel de administración
- **Devise** - Autenticación para admin
- **Google ID Token** - OAuth con Google
- **PostgreSQL** - Base de datos robusta y escalable
- **Rack-CORS** - Configuración CORS para APIs

## 🚀 Instalación Rápida

### Prerrequisitos

- Ruby 3.1+
- Rails 7.2+
- PostgreSQL 12+ (o usar Docker)

### Pasos de Instalación

#### Opción A: Instalación Local con PostgreSQL

1. **Instalar PostgreSQL**
```bash
# macOS con Homebrew
brew install postgresql
brew services start postgresql

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql

# Windows - Descargar desde postgresql.org
```

2. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/rails-baas.git
cd rails-baas
```

3. **Configurar variables de entorno**
```bash
cp env.example .env
# Editar .env con tus configuraciones de PostgreSQL
```

4. **Instalar dependencias y configurar**
```bash
bundle install
rails db:create
rails db:migrate
rails db:seed
```

5. **Iniciar servidor**
```bash
rails server
```

#### Opción B: Docker (Recomendado para desarrollo)

1. **Clonar e iniciar con Docker**
```bash
git clone https://github.com/tu-usuario/rails-baas.git
cd rails-baas

# Opción 1: Comando directo
docker compose up --build

# Opción 2: Script helper
./scripts/docker-dev.sh start
```

2. **Comandos útiles con Docker**
```bash
./scripts/docker-dev.sh console   # Rails console
./scripts/docker-dev.sh db        # PostgreSQL console
./scripts/docker-dev.sh logs      # Ver logs
./scripts/docker-dev.sh stop      # Detener servicios
```

3. **¡Listo!** 🎉
- API: http://localhost:3000
- Panel Admin: http://localhost:3000/admin
- PostgreSQL: localhost:5432
- Credenciales admin: `admin@rails-baas.com` / `password123`

## 📚 Documentación de la API

### Swagger UI - Documentación Interactiva
La API incluye documentación interactiva completa usando Swagger/OpenAPI 3.0:

- **URL**: http://localhost:3000/api-docs
- **Especificación YAML**: http://localhost:3000/swagger/v1/swagger.yaml
- **Especificación JSON**: http://localhost:3000/swagger/v1/swagger.json

### Características de la Documentación
- ✅ **Interactiva** - Prueba endpoints directamente desde el navegador
- ✅ **Autenticación JWT** - Configuración automática de tokens
- ✅ **Ejemplos** - Request/response examples para cada endpoint
- ✅ **Validación** - Esquemas completos con validaciones
- ✅ **Categorizada** - Endpoints organizados por funcionalidad

### Uso de Swagger UI
1. Accede a http://localhost:3000/api-docs
2. Autentícate usando el endpoint `/api/auth/login`
3. Copia el token JWT de la respuesta
4. Haz clic en "Authorize" en Swagger UI
5. Ingresa el token como `Bearer <tu-token>`
6. ¡Prueba todos los endpoints protegidos!

### Endpoints de Autenticación

#### Registro de Usuario
```bash
POST /api/auth/register
Content-Type: application/json

{
  "user": {
    "email": "usuario@ejemplo.com",
    "password": "contraseña123",
    "first_name": "Juan",
    "last_name": "Pérez"
  }
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "user": {
      "id": 1,
      "email": "usuario@ejemplo.com",
      "first_name": "Juan",
      "last_name": "Pérez",
      "full_name": "Juan Pérez",
      "confirmed": true,
      "google_user": false
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

#### Inicio de Sesión
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123"
}
```

#### Autenticación con Google
```bash
POST /api/auth/google
Content-Type: application/json

{
  "google_token": "TOKEN_DE_GOOGLE_AQUI"
}
```

#### Obtener Perfil del Usuario
```bash
GET /api/auth/me
Authorization: Bearer TU_JWT_TOKEN_AQUI
```

### Endpoints de Usuarios

#### Listar Usuarios (con filtros y paginación)
```bash
GET /api/users?page=1&per_page=10&search=juan&confirmed=true
Authorization: Bearer TU_JWT_TOKEN_AQUI
```

**Parámetros de consulta:**
- `page`: Número de página (default: 1)
- `per_page`: Elementos por página (max: 100, default: 10)
- `search`: Buscar por email, nombre o apellido
- `confirmed`: `true` o `false` para filtrar por estado de confirmación
- `provider`: `google` o `local` para filtrar por proveedor
- `order_by`: Campo de ordenamiento (`created_at`, `email`, `first_name`, `last_name`)
- `order_direction`: `asc` o `desc`

#### Ver Usuario Específico
```bash
GET /api/users/:id
Authorization: Bearer TU_JWT_TOKEN_AQUI
```

#### Actualizar Usuario
```bash
PUT /api/users/:id
Authorization: Bearer TU_JWT_TOKEN_AQUI
Content-Type: application/json

{
  "user": {
    "first_name": "Juan Carlos",
    "last_name": "Pérez López"
  }
}
```

#### Eliminar Usuario
```bash
DELETE /api/users/:id
Authorization: Bearer TU_JWT_TOKEN_AQUI
```

### Información del Sistema

#### Estado de la API
```bash
GET /api/info
```

Esta ruta pública devuelve información sobre:
- Estado de la API
- Características habilitadas
- Ejemplos de uso
- Instrucciones de configuración

## 🔧 Configuración

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
# Base de datos (para producción)
DATABASE_URL=postgresql://usuario:password@localhost/rails_baas_production

# Google OAuth (opcional)
GOOGLE_CLIENT_ID=tu_client_id_de_google.apps.googleusercontent.com

# Clave secreta (para producción)
SECRET_KEY_BASE=tu_clave_secreta_super_larga_y_segura
```

### Configurar Google OAuth

1. Ve a [Google Cloud Console](https://console.developers.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la API de Google Identity
4. Crea credenciales OAuth 2.0
5. Agrega tu dominio a los orígenes autorizados
6. Configura la variable `GOOGLE_CLIENT_ID`

### Configurar Base de Datos para Producción

Para cambiar a PostgreSQL:

1. Actualiza el `Gemfile`:
```ruby
gem 'pg', '~> 1.1'
```

2. Actualiza `config/database.yml`:
```yaml
production:
  adapter: postgresql
  encoding: unicode
  database: rails_baas_production
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>
  port: <%= ENV['DB_PORT'] %>
```

## 🏗️ Arquitectura del Proyecto

### Estructura de Directorios
```
app/
├── controllers/
│   ├── api/
│   │   ├── base_controller.rb      # Controlador base con JWT
│   │   ├── auth_controller.rb      # Autenticación
│   │   ├── users_controller.rb     # CRUD de usuarios
│   │   └── system_controller.rb    # Info del sistema
│   └── application_controller.rb   # Controlador raíz
├── models/
│   ├── user.rb                     # Modelo de usuario
│   └── admin_user.rb              # Modelo de admin
├── services/
│   ├── jwt_service.rb             # Servicio JWT
│   └── google_auth_service.rb     # Servicio Google OAuth
└── admin/
    ├── dashboard.rb               # Dashboard de ActiveAdmin
    └── users.rb                   # Gestión de usuarios
```

### Arquitectura Híbrida

Este BaaS usa una **arquitectura híbrida** que combina:

1. **API REST** (`/api/*`): Endpoints JSON para aplicaciones cliente
2. **Panel Web** (`/admin`): ActiveAdmin para gestión administrativa
3. **Controladores especializados**:
   - `Api::BaseController < ActionController::API` - Para endpoints API
   - `ApplicationController < ActionController::Base` - Para vistas web

### Patrones de Diseño

1. **Servicios**: Lógica de negocio encapsulada en clases de servicio
2. **Controlador Base**: Funcionalidad común para todos los endpoints API
3. **Respuestas Consistentes**: Formato estándar para todas las respuestas
4. **Manejo de Errores**: Captura y formato uniforme de errores
5. **Validaciones**: Validaciones robustas en modelos y controladores
6. **Arquitectura híbrida**: API + Web en la misma aplicación

## 🧪 Testing

### Ejecutar Tests
```bash
# Ejecutar todos los tests
bundle exec rspec

# Ejecutar tests específicos
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/controllers/api/auth_controller_spec.rb
```

### Estructura de Tests
```
spec/
├── models/
│   └── user_spec.rb
├── controllers/
│   └── api/
│       ├── auth_controller_spec.rb
│       └── users_controller_spec.rb
├── services/
│   ├── jwt_service_spec.rb
│   └── google_auth_service_spec.rb
└── factories/
    └── users.rb
```

## 🚀 Despliegue

### Heroku

1. **Preparar aplicación**
```bash
# Agregar Heroku remote
heroku create tu-app-baas

# Configurar variables de entorno
heroku config:set SECRET_KEY_BASE=$(rails secret)
heroku config:set GOOGLE_CLIENT_ID=tu_client_id
```

2. **Desplegar**
```bash
git push heroku main
heroku run rails db:migrate
heroku run rails db:seed
```

### Docker

```dockerfile
# Dockerfile incluido en el proyecto
FROM ruby:3.1

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

COPY . .
RUN rails assets:precompile

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```

```bash
# Construir y ejecutar
docker build -t rails-baas .
docker run -p 3000:3000 rails-baas
```

## 📈 Monitoreo y Logging

### Health Check
```bash
GET /up
```

### Logs de la Aplicación
```bash
# En desarrollo
tail -f log/development.log

# En producción
heroku logs --tail
```

### Métricas Disponibles
- Total de usuarios
- Usuarios activos
- Registros por día/semana/mes
- Errores de autenticación
- Uso de endpoints

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crea un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

- **Documentación**: Ver `/api/info` para documentación en vivo
- **Issues**: [GitHub Issues](https://github.com/tu-usuario/rails-baas/issues)
- **Email**: support@tu-dominio.com

## 🔧 Troubleshooting

Si encuentras problemas, usa nuestro script de diagnóstico:

```bash
./scripts/troubleshoot.sh
```

### Problemas Comunes

#### Error: "yaml.h not found"
✅ **Solucionado**: Agregamos `libyaml-dev` al Dockerfile

#### Error: "Missing secret_key_base"
✅ **Solucionado**: El Dockerfile genera una clave automáticamente

#### Error: "undefined method `layout' for ActiveAdmin"
✅ **Solucionado**: Configuración híbrida API + Web para ActiveAdmin

#### Error: "active_admin.css is not present in the asset pipeline"
✅ **Solucionado**: Pipeline de assets configurado correctamente

#### Error: "undefined method `delete' for :warning:Symbol"
✅ **Solucionado**: Sintaxis de status_tag corregida en ActiveAdmin

#### Error: "relation 'active_admin_comments' does not exist"
✅ **Solucionado**: Comentarios de ActiveAdmin deshabilitados

#### Error: "verify_authenticity_token has not been defined"
✅ **Solucionado**: Controladores API usando ActionController::Base en lugar de ActionController::API

#### Error: "undefined method `id' for nil:NilClass"
✅ **Solucionado**: Verificación de autenticación agregada a endpoints protegidos

#### Error: "Port 3000 already in use"
```bash
# Ver qué está usando el puerto
lsof -i :3000

# Detener todos los contenedores
docker compose down
```

#### Error: "Database does not exist"
```bash
# Recrear base de datos
docker compose exec app rails db:create db:migrate db:seed
```

#### Contenedores no inician
```bash
# Limpiar todo y empezar de cero
docker compose down -v
docker system prune -f
docker compose up --build
```

## 🎯 Roadmap

- [ ] Rate limiting
- [ ] Roles y permisos avanzados
- [ ] Notificaciones push
- [ ] Integración con más proveedores OAuth
- [ ] Sistema de archivos/uploads
- [ ] Cache con Redis
- [ ] Documentación con Swagger/OpenAPI
- [ ] Tests de integración completos

---

⭐ **¡Si este proyecto te fue útil, no olvides darle una estrella!** ⭐