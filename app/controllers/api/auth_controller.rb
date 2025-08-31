# Controlador para manejar autenticación (login, register, logout)
class Api::AuthController < Api::AuthBaseController
  
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
  
  # POST /api/auth/logout
  # Cerrar sesión (invalidar token)
  def logout
    return unless authenticate_user!
    
    # En JWT, el logout se maneja del lado del cliente eliminando el token
    # Aquí podríamos implementar una lista negra de tokens si fuera necesario
    
    render_success({}, 'Sesión cerrada exitosamente')
  end
  
  # GET /api/auth/me
  # Obtener información del usuario actual
  def me
    return unless authenticate_user!
    
    render_success({
      user: user_response(current_user)
    }, 'Información del usuario obtenida')
  end
  
  # PUT /api/auth/profile
  # Actualizar perfil del usuario
  def update_profile
    return unless authenticate_user!
    
    if current_user.update(user_update_params)
      render_success({
        user: user_response(current_user)
      }, 'Perfil actualizado exitosamente')
    else
      render_error(
        'Error al actualizar perfil',
        :unprocessable_entity,
        current_user.errors.full_messages
      )
    end
  end
  
  private
  
  # Método para obtener el usuario actual desde el token JWT
  def current_user
    @current_user ||= authenticate_user_from_token
  end
  
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
end
