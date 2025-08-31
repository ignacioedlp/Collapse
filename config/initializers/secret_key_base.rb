# Configuración robusta para SECRET_KEY_BASE
# Asegura que siempre tengamos una clave secreta válida

if Rails.env.development? || Rails.env.test?
  # En desarrollo y test, usar una clave fija para consistencia
  Rails.application.credentials.secret_key_base ||= 'development_secret_key_base_for_rails_baas_' + ('a' * 32)
elsif Rails.env.production?
  # En producción, requerir SECRET_KEY_BASE del entorno
  if ENV['SECRET_KEY_BASE'].blank?
    Rails.logger.error "SECRET_KEY_BASE no está configurado en producción"
    Rails.logger.error "Configúralo con: export SECRET_KEY_BASE=$(rails secret)"
    raise "Missing SECRET_KEY_BASE for production environment"
  end
else
  # Para otros entornos (como docker), generar una temporal si no existe
  Rails.application.credentials.secret_key_base ||= SecureRandom.hex(64)
end
