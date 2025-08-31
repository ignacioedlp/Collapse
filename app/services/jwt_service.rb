# Servicio para manejar tokens JWT
# Este servicio encapsula toda la lógica de JWT en un solo lugar
class JwtService
  # Clave secreta para firmar los tokens (en producción debe estar en credentials)
  SECRET_KEY = Rails.application.credentials.secret_key_base.to_s
  
  # Algoritmo de encriptación
  ALGORITHM = 'HS256'
  
  # Tiempo de expiración del token (24 horas)
  EXPIRATION_TIME = 5.weeks.from_now
  
  # Método para generar un token JWT
  # @param payload [Hash] Los datos que queremos incluir en el token
  # @return [String] El token JWT generado
  def self.encode(payload)
    # Agregamos la fecha de expiración al payload
    payload[:exp] = EXPIRATION_TIME.to_i
    
    # Generamos el token usando la gema JWT
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end
  
  # Método para decodificar y validar un token JWT
  # @param token [String] El token JWT a decodificar
  # @return [Hash] Los datos decodificados del token
  def self.decode(token)
    # Decodificamos el token y obtenemos el payload
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
    
    # Retornamos el primer elemento que contiene el payload
    decoded[0]
  rescue JWT::DecodeError => e
    # Si hay error al decodificar, retornamos nil
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end
  
  # Método para generar un token para un usuario específico
  # @param user [User] El usuario para el cual generar el token
  # @return [String] El token JWT
  def self.generate_user_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      iat: Time.current.to_i # issued at (cuándo se emitió)
    }
    
    encode(payload)
  end
  
  # Método para validar un token y obtener el usuario
  # @param token [String] El token a validar
  # @return [User, nil] El usuario si el token es válido, nil si no
  def self.get_user_from_token(token)
    decoded_token = decode(token)
    return nil unless decoded_token
    
    # Buscamos el usuario por ID
    user = User.find_by(id: decoded_token['user_id'])
    
    # Verificamos que el usuario exista y esté confirmado
    return nil unless user&.confirmed?
    
    user
  rescue ActiveRecord::RecordNotFound
    nil
  end
  
  # Método para verificar si un token ha expirado
  # @param token [String] El token a verificar
  # @return [Boolean] true si ha expirado, false si no
  def self.expired?(token)
    decoded_token = decode(token)
    return true unless decoded_token
    
    # Comparamos la fecha de expiración con el tiempo actual
    Time.at(decoded_token['exp']) < Time.current
  rescue
    true
  end
end
