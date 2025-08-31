# Concern para manejar respuestas de usuario de manera consistente
module UserResponseConcern
  extend ActiveSupport::Concern
  
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
end
