# Servicio para manejar autenticación con Google OAuth
# Valida tokens de Google y extrae información del usuario
class GoogleAuthService
  # Excepción personalizada para tokens inválidos
  class InvalidTokenError < StandardError; end

  # ID de cliente de Google OAuth (debe configurarse en credentials)
  GOOGLE_CLIENT_ID = Rails.application.credentials.dig(:google, :client_id) ||
    ENV.fetch('GOOGLE_CLIENT_ID', nil)

  # Validar token de Google y obtener información del usuario
  # @param token [String] El token ID de Google
  # @return [Hash] Información del usuario de Google
  # @raise [InvalidTokenError] Si el token es inválido
  def self.validate_token(token)
    # Verificar que tenemos configurado el client ID
    unless GOOGLE_CLIENT_ID.present?
      Rails.logger.error 'Google Client ID not configured'
      raise InvalidTokenError, 'Google authentication not properly configured'
    end

    begin
      # Usar la gema google-id-token para validar el token
      validator = GoogleIDToken::Validator.new

      # Validar el token contra Google
      payload = validator.check(token, GOOGLE_CLIENT_ID)

      # Si el token es válido, retornar la información del usuario
      raise InvalidTokenError, 'Invalid Google token' unless payload

      {
        'sub' => payload['sub'],           # ID único de Google
        'email' => payload['email'],       # Email del usuario
        'given_name' => payload['given_name'], # Nombre
        'family_name' => payload['family_name'], # Apellido
        'name' => payload['name'],         # Nombre completo
        'picture' => payload['picture']    # URL de la foto de perfil
      }
    rescue GoogleIDToken::ValidationError => e
      Rails.logger.error "Google token validation error: #{e.message}"
      raise InvalidTokenError, "Google token validation failed: #{e.message}"
    rescue => e
      Rails.logger.error "Google auth service error: #{e.message}"
      raise InvalidTokenError, 'Google authentication failed'
    end
  end

  # Verificar si Google Auth está configurado correctamente
  # @return [Boolean] true si está configurado, false si no
  def self.configured?
    GOOGLE_CLIENT_ID.present?
  end

  # Obtener la URL de configuración para Google OAuth
  # @return [String] URL donde configurar la aplicación en Google
  def self.setup_url
    'https://console.developers.google.com/apis/credentials'
  end

  # Obtener instrucciones de configuración
  # @return [Hash] Instrucciones para configurar Google OAuth
  def self.setup_instructions
    {
      message: 'Para configurar Google OAuth:',
      steps: [
        "1. Ve a #{setup_url}",
        '2. Crea un nuevo proyecto o selecciona uno existente',
        '3. Habilita la API de Google+ o Google Identity',
        "4. Crea credenciales de tipo 'OAuth 2.0 Client IDs'",
        '5. Configura los dominios autorizados',
        '6. Copia el Client ID y agrégalo a las credentials de Rails:',
        '   rails credentials:edit',
        '   google:',
        "     client_id: 'tu_client_id_aqui'",
        '7. O configura la variable de entorno GOOGLE_CLIENT_ID'
      ],
      current_status: configured? ? '✅ Configurado' : '❌ No configurado'
    }
  end
end
