# Controlador para manejar autenticación (login, register, logout)
class Api::AuthController < ActionController::Base
  # Omitir la verificación CSRF para API
  skip_before_action :verify_authenticity_token
  
  # Manejar errores de autenticación
  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  
  # POST /api/auth/register
  # Registrar un nuevo usuario con email y contraseña
  def register
    # Crear nuevo usuario con los parámetros recibidos
    user = User.new(user_registration_params)
    
    if user.save
      # Si el usuario se guardó exitosamente, generar token
      token = JwtService.generate_user_token(user)
      
      render_success({
        user: user_response(user),
        token: token
      }, 'Usuario registrado exitosamente', :created)
    else
      # Si hay errores de validación, retornarlos
      render_error(
        'Error al registrar usuario',
        :unprocessable_entity,
        user.errors.full_messages
      )
    end
  end
  
  # POST /api/auth/login
  # Iniciar sesión con email y contraseña
  def login
    # Buscar usuario por email (case insensitive)
    user = User.find_by('LOWER(email) = ?', params[:email]&.downcase)
    
    # Verificar que el usuario existe y la contraseña es correcta
    if user && user.authenticate(params[:password])
      # Verificar que el usuario esté confirmado
      unless user.confirmed?
        return render_error(
          'Debes confirmar tu cuenta antes de iniciar sesión',
          :unauthorized
        )
      end
      
      # Generar token JWT
      token = JwtService.generate_user_token(user)
      
      render_success({
        user: user_response(user),
        token: token
      }, 'Inicio de sesión exitoso')
    else
      render_error(
        'Email o contraseña incorrectos',
        :unauthorized
      )
    end
  end
  
  # POST /api/auth/google
  # Autenticación con Google OAuth
  def google_auth
    # Validar el token de Google
    google_token = params[:google_token]
    
    unless google_token.present?
      return render_error('Token de Google requerido', :bad_request)
    end
    
    begin
      # Validar el token con Google
      google_user_info = GoogleAuthService.validate_token(google_token)
      
      # Crear o encontrar usuario basado en la información de Google
      user = User.from_google(google_user_info)
      
      # Generar token JWT para nuestro sistema
      token = JwtService.generate_user_token(user)
      
      render_success({
        user: user_response(user),
        token: token
      }, 'Autenticación con Google exitosa')
      
    rescue GoogleAuthService::InvalidTokenError => e
      render_error('Token de Google inválido', :unauthorized)
    rescue StandardError => e
      Rails.logger.error "Google Auth Error: #{e.message}"
      render_error('Error en autenticación con Google', :internal_server_error)
    end
  end

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
      updated_at: user.updated_at,
      roles: user.roles.map(&:name)
    }
  end
end
