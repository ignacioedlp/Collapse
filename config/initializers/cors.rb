# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # En desarrollo, permitir cualquier origen
    # En producción, especifica los dominios exactos
    origins Rails.env.development? ? '*' : ['https://tu-frontend.com', 'https://tu-app.com']

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false # Cambiar a true si necesitas cookies/auth headers
  end
  
  # Configuración específica para rutas de API
  allow do
    origins Rails.env.development? ? '*' : ['https://tu-frontend.com']
    
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false,
      max_age: 86400 # Cache preflight por 24 horas
  end
end
