# Controlador base para endpoints de autenticación
# No requiere autenticación previa
class Api::AuthBaseController < ActionController::Base
  # Omitir la verificación CSRF para API
  skip_before_action :verify_authenticity_token
  
  # Manejar errores de autenticación
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  
  private
  
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
  
  # Parámetros permitidos para registro de usuario
  def user_registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end
  
  # Parámetros permitidos para login
  def user_login_params
    params.permit(:email, :password)
  end
  
  # Parámetros permitidos para actualización de perfil
  def user_update_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
  
  # Respuesta estándar de usuario (sin información sensible)
  def user_response(user)
    return nil unless user
    
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      provider: user.provider,
      google_id: user.google_id,
      confirmed: user.confirmed?,
      confirmed_at: user.confirmed_at,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
  
  # Verificar que el usuario esté autenticado
  def authenticate_user!
    unless current_user
      render_error(
        'Token inválido o expirado',
        :unauthorized
      )
      return false
    end
    true
  end
end
