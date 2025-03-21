Devise.setup do |config|
  config.mailer_sender = "no-reply@example.com"
  require "devise/orm/active_record"

  # Confirmable
  config.confirm_within = 3.days
  config.reconfirmable = true

  # Lockable
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :time
  config.maximum_attempts = 5
  config.unlock_in = 1.hour

  # JWT Config
  config.jwt do |jwt|
    jwt.secret = ENV["DEVISE_JWT_SECRET_KEY"]
    jwt.dispatch_requests = [ [ "POST", %r{^/api/v1/login$} ] ]
    jwt.revocation_requests = [ [ "DELETE", %r{^/api/v1/logout$} ] ]
    jwt.expiration_time = 30.minutes.to_i
  end

  config.omniauth :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], scope: "user:email", provider_ignores_state: true
  config.omniauth :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"],
                  scope: "userinfo.email,userinfo.profile",
                  prompt: "select_account",
                  provider_ignores_state: true
end
