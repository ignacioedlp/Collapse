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
    # Rutas de autenticación
    scope :auth do
      post :register, to: 'auth#register'
      post :login, to: 'auth#login'
      post :logout, to: 'auth#logout'
      post :google, to: 'auth#google_auth'
      get :me, to: 'auth#me'
      put :profile, to: 'auth#update_profile'
    end
    
    # Rutas de usuarios (CRUD completo)
    resources :users, only: [:index, :show, :update, :destroy]
    
    # Ruta de información del sistema
    get :info, to: 'system#info'
  end

  # Ruta raíz para mostrar información de la API
  root 'application#index'
end
