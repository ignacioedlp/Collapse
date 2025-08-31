# Configuración específica para Docker development
# Este archivo se carga cuando RAILS_ENV=docker

require_relative "development"

Rails.application.configure do
  # Configuración específica para Docker
  config.hosts << "app"
  config.hosts << "localhost"
  config.hosts << /.*\.docker\.internal/
  
  # Permitir conexiones desde cualquier host en Docker
  config.web_console.whitelisted_ips = %w( 0.0.0.0/0 ::/0 )
  
  # Assets para ActiveAdmin en Docker
  config.assets.compile = true
  config.assets.digest = false
  
  # Logs más verbosos para debugging
  config.log_level = :debug
  
  # Cache store simple para desarrollo
  config.cache_store = :memory_store
  
  # No verificar SSL en desarrollo
  config.force_ssl = false
end
