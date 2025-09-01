class Rack::Attack
  # Configuración de cache (usar Redis en producción)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Configuración de rate limiting para diferentes endpoints
  
  # Rate limiting para registro de usuarios (más restrictivo)
  throttle('register/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/api/auth/register' && req.post?
  end

  # Rate limiting para login (más restrictivo)
  throttle('login/ip', limit: 10, period: 1.hour) do |req|
    req.ip if req.path == '/api/auth/login' && req.post?
  end

  # Rate limiting para Google OAuth
  throttle('google_auth/ip', limit: 20, period: 1.hour) do |req|
    req.ip if req.path == '/api/auth/google' && req.post?
  end

  # Rate limiting general para API (por IP)
  throttle('api/ip', limit: 1000, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Rate limiting por usuario autenticado (más permisivo)
  throttle('api/user', limit: 5000, period: 1.hour) do |req|
    if req.path.start_with?('/api/') && req.get?
      # Extraer user_id del token JWT si está disponible
      token = req.get_header('HTTP_AUTHORIZATION')&.split(' ')&.last
      if token
        begin
          user = JwtService.get_user_from_token(token)
          user&.id
        rescue
          nil
        end
      end
    end
  end

  # Rate limiting para endpoints de escritura por usuario
  throttle('api/user/write', limit: 1000, period: 1.hour) do |req|
    if req.path.start_with?('/api/') && (req.post? || req.put? || req.patch? || req.delete?)
      token = req.get_header('HTTP_AUTHORIZATION')&.split(' ')&.last
      if token
        begin
          user = JwtService.get_user_from_token(token)
          user&.id
        rescue
          nil
        end
      end
    end
  end

  # Bloquear IPs maliciosas (opcional)
  blocklist('blocklist') do |req|
    # Lista de IPs bloqueadas (puede venir de base de datos)
    blocked_ips = []
    blocked_ips.include?(req.ip)
  end

  # Bloquear requests sospechosos
  blocklist('suspicious') do |req|
    # Bloquear requests con User-Agent sospechoso
    req.user_agent&.match?(/bot|crawler|spider/i) && 
    !req.user_agent&.match?(/googlebot|bingbot/i) # Permitir bots legítimos
  end

  # Configurar respuestas personalizadas
  self.blocklisted_response = lambda do |env|
    [429, {'Content-Type' => 'application/json'}, [{
      success: false,
      error: 'rate_limit_exceeded',
      message: 'Demasiadas solicitudes. Por favor, intenta de nuevo más tarde.',
      retry_after: env['rack.attack.match_data'][:period]
    }.to_json]]
  end

  self.throttled_response = lambda do |env|
    [429, {'Content-Type' => 'application/json'}, [{
      success: false,
      error: 'rate_limit_exceeded',
      message: 'Has excedido el límite de solicitudes. Por favor, intenta de nuevo más tarde.',
      retry_after: env['rack.attack.match_data'][:period],
      limit: env['rack.attack.match_data'][:limit],
      remaining: env['rack.attack.match_data'][:count]
    }.to_json]]
  end

  # Logging para debugging
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    req = payload[:request]
    if req.env['rack.attack.match_type'] == :throttle
      Rails.logger.warn "Rate limit exceeded: #{req.ip} - #{req.path}"
    elsif req.env['rack.attack.match_type'] == :blocklist
      Rails.logger.warn "Request blocked: #{req.ip} - #{req.path}"
    end
  end
end
