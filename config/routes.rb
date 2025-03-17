Rails.application.routes.draw do
  # Administration
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # User authentication
  devise_for :users, controllers: {
      registrations: "users/registrations",
      confirmations: "users/confirmations",
      passwords: "users/passwords",
      sessions: "users/sessions"
    }

  # API
  namespace :api do
    namespace :v1 do
      # User authentication
      post "register", to: "auth#register"
      post "login", to: "auth#login"
      delete "logout", to: "auth#logout"
      post "resend_confirmation", to: "auth#resend_confirmation"
      post "github", to: "auth#github"
      post "google", to: "auth#google"

      # Users management
      resources :users, only: [ :index, :show, :update, :destroy ] do
        member do
          # User management
          post "ban", to: "users#ban"
          post "unban", to: "users#unban"
        end
      end

      resource :profile, only: [ :show, :update ], controller: "profile"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Swagger
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
end
