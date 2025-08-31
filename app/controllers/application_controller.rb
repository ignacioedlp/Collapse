class ApplicationController < ActionController::Base
  # Configurar para comportamiento híbrido API/Web
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  # Ruta raíz que muestra información básica de la API
  def index
    render json: {
      message: '¡Bienvenido a Rails BaaS!',
      description: 'Backend as a Service construido con Ruby on Rails',
      version: '1.0.0',
      documentation: {
        api_info: request.base_url + '/api/info',
        admin_panel: request.base_url + '/admin',
        health_check: request.base_url + '/up'
      },
      quick_start: {
        '1': 'Registra un usuario: POST /api/auth/register',
        '2': 'Inicia sesión: POST /api/auth/login',
        '3': 'Usa el token JWT en el header Authorization: Bearer <token>',
        '4': 'Accede a endpoints protegidos como /api/auth/me'
      },
      support: {
        repository: 'https://github.com/tu-usuario/rails-baas',
        issues: 'https://github.com/tu-usuario/rails-baas/issues',
        email: 'support@tu-dominio.com'
      }
    }, status: :ok
  end
end
