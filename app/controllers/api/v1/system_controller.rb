# Controlador para información del sistema y estado de la API
module Api
  module V1
    class SystemController < Api::V1::BaseController
      # GET /api/info
      # Información general del sistema y estado de la API
      def info
        render_success({
          api: {
            name: 'Rails BaaS API',
            version: '1.0.0',
            description: 'Backend as a Service construido con Ruby on Rails',
            documentation_url: "#{request.base_url}/api-docs",
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
              url: "#{request.base_url}/admin"
            }
          }
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
    end
  end
end
