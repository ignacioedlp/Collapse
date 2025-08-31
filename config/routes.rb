Rails.application.routes.draw do
  # ActiveAdmin routes
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    # Rutas de autenticación (v1 - sin versionar para mantener compatibilidad)
    scope :auth do
      post :register, to: 'auth#register'
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
      post :google, to: 'auth#google_auth'
    end
    
    # API v1 - Rutas versionadas
    namespace :v1 do
      # Rutas usuarios
      get :me, to: 'me#show'
      put :me, to: 'me#edit'
      
      # Ruta de información del sistema
      get :info, to: 'system#info'
    end
  end

  # Ruta raíz para mostrar información de la API
  root 'application#index'
  
  # Swagger UI
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  # Swagger JSON and YAML
  get '/swagger/v1/swagger.yaml', to: 'swagger#yaml'
  get '/swagger/v1/swagger.json', to: 'swagger#index'
end
