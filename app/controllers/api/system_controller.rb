# Controlador para información del sistema y estado de la API
class Api::SystemController < Api::BaseController
  # Omitir autenticación para información pública del sistema
  skip_before_action :authenticate_user!, only: [:info]
  
  # GET /api/info
  # Información general del sistema y estado de la API
  def info
    render_success({
      api: {
        name: 'Rails BaaS API',
        version: '1.0.0',
        description: 'Backend as a Service construido con Ruby on Rails',
        documentation_url: request.base_url + '/api-docs',
        status: 'operational'
      },
      features: {
        authentication: {
          jwt: true,
          google_oauth: GoogleAuthService.configured?,
          password_auth: true
        },
        database: {
          adapter: Rails.configuration.database_configuration[Rails.env]['adapter'],
          status: database_status
        },
        admin_panel: {
          enabled: true,
          url: request.base_url + '/admin'
        }
      },
      endpoints: {
        auth: {
          register: 'POST /api/auth/register',
          login: 'POST /api/auth/login',
          google_auth: 'POST /api/auth/google',
          logout: 'POST /api/auth/logout',
          profile: 'GET /api/auth/me',
          update_profile: 'PUT /api/auth/profile'
        },
        users: {
          list: 'GET /api/users',
          show: 'GET /api/users/:id',
          update: 'PUT /api/users/:id',
          delete: 'DELETE /api/users/:id'
        },
        system: {
          info: 'GET /api/info',
          health: 'GET /up'
        }
      },
      usage_examples: usage_examples,
      setup_instructions: setup_instructions
    }, 'Información del sistema obtenida exitosamente')
  end
  
  private
  
  # Verificar estado de la base de datos
  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'connected'
  rescue
    'disconnected'
  end
  
  # Ejemplos de uso de la API
  def usage_examples
    base_url = request.base_url
    
    {
      register: {
        method: 'POST',
        url: "#{base_url}/api/auth/register",
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          user: {
            email: 'usuario@ejemplo.com',
            password: 'contraseña123',
            first_name: 'Juan',
            last_name: 'Pérez'
          }
        }
      },
      login: {
        method: 'POST',
        url: "#{base_url}/api/auth/login",
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          email: 'usuario@ejemplo.com',
          password: 'contraseña123'
        }
      },
      authenticated_request: {
        method: 'GET',
        url: "#{base_url}/api/auth/me",
        headers: {
          'Authorization' => 'Bearer YOUR_JWT_TOKEN_HERE',
          'Content-Type' => 'application/json'
        }
      },
      google_auth: {
        method: 'POST',
        url: "#{base_url}/api/auth/google",
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          google_token: 'GOOGLE_ID_TOKEN_HERE'
        }
      }
    }
  end
  
  # Instrucciones de configuración
  def setup_instructions
    instructions = {
      database: [
        "1. Configura tu base de datos en config/database.yml",
        "2. Ejecuta: rails db:create db:migrate",
        "3. (Opcional) Ejecuta: rails db:seed para datos de prueba"
      ],
      google_oauth: [],
      admin_panel: [
        "1. Ejecuta: rails generate active_admin:install",
        "2. Ejecuta: rails db:migrate",
        "3. Crea un usuario admin: rails db:seed",
        "4. Accede a #{request.base_url}/admin"
      ],
      production: [
        "1. Configura variables de entorno:",
        "   - SECRET_KEY_BASE",
        "   - GOOGLE_CLIENT_ID (opcional)",
        "   - DATABASE_URL",
        "2. Configura CORS en config/initializers/cors.rb",
        "3. Configura SSL en producción",
        "4. Implementa rate limiting si es necesario"
      ]
    }
    
    # Agregar instrucciones específicas de Google OAuth
    if GoogleAuthService.configured?
      instructions[:google_oauth] = ["✅ Google OAuth está configurado correctamente"]
    else
      instructions[:google_oauth] = GoogleAuthService.setup_instructions[:steps]
    end
    
    instructions
  end
end
