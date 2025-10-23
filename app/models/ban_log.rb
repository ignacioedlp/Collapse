class BanLog < ApplicationRecord
  # Relaciones
  belongs_to :user
  belongs_to :admin_user
  
  # Validaciones
  validates :action, presence: true, inclusion: { in: %w[banned unbanned auto_banned] }
  validates :reason, presence: true, length: { minimum: 3, maximum: 1000 }
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :bans, -> { where(action: ['banned', 'auto_banned']) }
  scope :unbans, -> { where(action: 'unbanned') }
  scope :auto_bans, -> { where(action: 'auto_banned') }
  scope :for_user, ->(user) { where(user: user) }
  scope :by_admin, ->(admin) { where(admin_user: admin) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }
  
  # Métodos de clase para estadísticas
  def self.ransackable_attributes(_auth_object = nil)
    %w[action created_at reason user_id admin_user_id banned_until ip_address]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user admin_user]
  end
  
  # Métodos de instancia
  def ban_action?
    %w[banned auto_banned].include?(action)
  end
  
  def unban_action?
    action == 'unbanned'
  end
  
  def automatic?
    action == 'auto_banned'
  end
  
  def temporary_ban?
    ban_action? && banned_until.present?
  end
  
  def permanent_ban?
    ban_action? && banned_until.nil?
  end
  
  def formatted_action
    case action
    when 'banned'
      'Baneado manualmente'
    when 'unbanned'
      'Desbaneado'
    when 'auto_banned'
      'Baneado automáticamente'
    end
  end
  
  def duration_description
    return 'N/A' if unban_action?
    return 'Permanente' if permanent_ban?
    
    if banned_until > Time.current
      "Hasta #{banned_until.strftime('%d/%m/%Y %H:%M')}"
    else
      "Expiró el #{banned_until.strftime('%d/%m/%Y %H:%M')}"
    end
  end
end