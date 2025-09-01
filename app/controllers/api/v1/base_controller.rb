# Controlador base para la API v1
# Hereda del controlador base general y puede tener configuraciones específicas de v1
module Api
  module V1
    class BaseController < Api::BaseController
      # Aquí puedes agregar configuraciones específicas de la versión 1
      # Por ejemplo, diferentes formatos de respuesta, validaciones específicas, etc.

      # Ejemplo: Agregar headers específicos de la versión
      after_action :add_version_header

      private

      def add_version_header
        response.headers['X-API-Version'] = 'v1'
      end
    end
  end
end
