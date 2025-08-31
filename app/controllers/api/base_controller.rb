# Controlador base para todos los endpoints de la API
# Incluye autenticación JWT y manejo de errores común
class Api::BaseController < ActionController::Base
  # Omitir la verificación CSRF para API
  skip_before_action :verify_authenticity_token
  
  # Ejecutar autenticación antes de cada acción
  before_action :authenticate_user!
  
  # Manejar errores de autenticación
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  
  protected
  
  # Método para obtener el usuario actual desde el token JWT
  def current_user
    @current_user ||= authenticate_user_from_token
  end
  
  # Verificar que el usuario esté autenticado
  def authenticate_user!
    unless current_user
      render json: { 
        error: 'Token inválido o expirado',
        message: 'Debes estar autenticado para acceder a este recurso'
      }, status: :unauthorized
    end
  end
  
  # Permitir acceso sin autenticación (útil para endpoints públicos)
  def skip_authentication
    # Este método puede ser llamado en controladores específicos
    # para omitir la autenticación en ciertas acciones
  end
  
  private
  
  # Extraer y validar el token JWT del header Authorization
  def authenticate_user_from_token
    # Obtener el header Authorization
    auth_header = request.headers['Authorization']
    
    # Verificar que existe y tiene el formato correcto
    return nil unless auth_header && auth_header.start_with?('Bearer ')
    
    # Extraer el token (remover "Bearer ")
    token = auth_header.split(' ').last
    
    # Obtener el usuario usando el servicio JWT
    JwtService.get_user_from_token(token)
  end
  
  # Renderizar respuesta de éxito estándar
  def render_success(data = {}, message = 'Operación exitosa', status = :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end
  
  # Renderizar respuesta de error estándar
  def render_error(message, status = :bad_request, errors = nil)
    response = {
      success: false,
      message: message
    }
    
    response[:errors] = errors if errors.present?
    
    render json: response, status: status
  end
  
  # Manejar errores estándar
  def handle_standard_error(exception)
    Rails.logger.error "API Error: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render_error(
      'Ha ocurrido un error interno del servidor',
      :internal_server_error
    )
  end
  
  # Manejar errores de registro no encontrado
  def handle_not_found(exception)
    render_error(
      'El recurso solicitado no fue encontrado',
      :not_found
    )
  end
  
  # Manejar errores de validación
  def handle_validation_error(exception)
    render_error(
      'Error de validación',
      :unprocessable_entity,
      exception.record.errors.full_messages
    )
  end
end
