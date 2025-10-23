class CheckAutoBanConditionsJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.is_a?(User)
    return if user.banned? # Ya está baneado
    
    # Configuración de reglas de auto-ban
    rules = {
      # Reportes en las últimas 24 horas
      reports_24h: { threshold: 5, duration: 24.hours },
      # Reportes de spam en las últimas 48 horas  
      spam_reports_48h: { threshold: 3, duration: 48.hours },
      # Reportes de acoso
      harassment_reports: { threshold: 2, duration: 12.hours },
      # Reportes de amenazas (baneo inmediato)
      threat_reports: { threshold: 1, duration: nil }
    }
    
    check_general_reports_rule(user, rules[:reports_24h])
    check_spam_reports_rule(user, rules[:spam_reports_48h])
    check_harassment_reports_rule(user, rules[:harassment_reports])
    check_threat_reports_rule(user, rules[:threat_reports])
  end

  private

  def check_general_reports_rule(user, rule)
    recent_reports = user.received_reports
                        .where('created_at >= ?', 24.hours.ago)
                        .count
                        
    return unless recent_reports >= rule[:threshold]
    
    auto_ban_user(
      user: user,
      reason: "Baneo automático: #{recent_reports} reportes en 24 horas",
      duration: rule[:duration]
    )
  end

  def check_spam_reports_rule(user, rule)
    spam_reports = user.received_reports
                      .where(reason: 'spam')
                      .where('created_at >= ?', 48.hours.ago)
                      .count
                      
    return unless spam_reports >= rule[:threshold]
    
    auto_ban_user(
      user: user,
      reason: "Baneo automático: #{spam_reports} reportes de spam en 48 horas",
      duration: rule[:duration]
    )
  end

  def check_harassment_reports_rule(user, rule)
    harassment_reports = user.received_reports
                            .where(reason: 'harassment')
                            .where('created_at >= ?', rule[:duration])
                            .count
                            
    return unless harassment_reports >= rule[:threshold]
    
    auto_ban_user(
      user: user,
      reason: "Baneo automático: #{harassment_reports} reportes de acoso",
      duration: 7.days # Baneo temporal por acoso
    )
  end

  def check_threat_reports_rule(user, rule)
    threat_reports = user.received_reports
                        .where(reason: 'threats')
                        .where('created_at >= ?', 1.hour.ago)
                        .count
                        
    return unless threat_reports >= rule[:threshold]
    
    auto_ban_user(
      user: user,
      reason: "Baneo automático: amenazas reportadas",
      duration: nil # Baneo permanente por amenazas
    )
  end

  def auto_ban_user(user:, reason:, duration:)
    # Obtener el admin del sistema para auto-bans
    system_admin = AdminUser.find_or_create_by(
      email: 'system@collapse.app'
    ) do |admin|
      admin.password = SecureRandom.hex(20)
      admin.active = false # Admin solo para sistema
    end

    # Banear al usuario
    user.ban!(
      reason: reason,
      admin_user: system_admin,
      until_date: duration&.from_now
    )

    # Notificar a los administradores
    notify_admins_about_auto_ban(user, reason)
    
    Rails.logger.info "Auto-ban aplicado: Usuario #{user.id} (#{user.email}) - #{reason}"
  end

  def notify_admins_about_auto_ban(user, reason)
    # Aquí podrías enviar emails a administradores o crear notificaciones
    # Por simplicidad, solo loggeamos
    Rails.logger.warn "AUTO-BAN APLICADO: Usuario #{user.full_name} (#{user.email}) - #{reason}"
    
    # Opcional: enviar email a administradores
    # AdminNotificationMailer.auto_ban_notification(user, reason).deliver_now
  end
end