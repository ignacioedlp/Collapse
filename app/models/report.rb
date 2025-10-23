class Report < ApplicationRecord
  # Relaciones
  belongs_to :reported_user, class_name: 'User'
  belongs_to :reporter, class_name: 'User'
  belongs_to :reviewed_by, class_name: 'AdminUser', optional: true
  
  # Validaciones
  validates :reason, presence: true, inclusion: { 
    in: %w[spam harassment inappropriate_content threats fake_profile other] 
  }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :status, presence: true, inclusion: { 
    in: %w[pending reviewed resolved dismissed] 
  }
  
  # No permitir auto-reportes
  validate :cannot_report_self
  
  # Prevenir reportes duplicados recientes
  validate :no_duplicate_recent_reports, on: :create
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: 'pending') }
  scope :reviewed, -> { where(status: 'reviewed') }
  scope :resolved, -> { where(status: 'resolved') }
  scope :dismissed, -> { where(status: 'dismissed') }
  scope :for_user, ->(user) { where(reported_user: user) }
  scope :by_reporter, ->(user) { where(reporter: user) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }
  scope :by_reason, ->(reason) { where(reason: reason) }
  
  # Callbacks
  after_create :check_auto_ban_conditions
  
  # Métodos de clase
  def self.ransackable_attributes(_auth_object = nil)
    %w[reason description status created_at reported_user_id reporter_id ip_address]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[reported_user reporter reviewed_by]
  end
  
  def self.reasons_for_select
    [
      ['Spam', 'spam'],
      ['Acoso/Hostigamiento', 'harassment'], 
      ['Contenido inapropiado', 'inappropriate_content'],
      ['Amenazas', 'threats'],
      ['Perfil falso', 'fake_profile'],
      ['Otro', 'other']
    ]
  end
  
  def self.statuses_for_select
    [
      ['Pendiente', 'pending'],
      ['Revisado', 'reviewed'],
      ['Resuelto', 'resolved'],
      ['Desestimado', 'dismissed']
    ]
  end
  
  # Métodos de instancia
  def pending?
    status == 'pending'
  end
  
  def reviewed?
    status == 'reviewed'
  end
  
  def resolved?
    status == 'resolved'
  end
  
  def dismissed?
    status == 'dismissed'
  end
  
  def formatted_reason
    case reason
    when 'spam' then 'Spam'
    when 'harassment' then 'Acoso/Hostigamiento'
    when 'inappropriate_content' then 'Contenido inapropiado'
    when 'threats' then 'Amenazas'
    when 'fake_profile' then 'Perfil falso'
    when 'other' then 'Otro'
    else reason.humanize
    end
  end
  
  def formatted_status
    case status
    when 'pending' then 'Pendiente'
    when 'reviewed' then 'Revisado'
    when 'resolved' then 'Resuelto'
    when 'dismissed' then 'Desestimado'
    else status.humanize
    end
  end
  
  def mark_as_reviewed!(admin_user, notes = nil)
    update!(
      status: 'reviewed',
      reviewed_by: admin_user,
      admin_notes: notes
    )
  end
  
  def resolve!(admin_user, notes = nil)
    update!(
      status: 'resolved',
      reviewed_by: admin_user,
      admin_notes: notes
    )
  end
  
  def dismiss!(admin_user, notes = nil)
    update!(
      status: 'dismissed',
      reviewed_by: admin_user,
      admin_notes: notes
    )
  end
  
  private
  
  def cannot_report_self
    return unless reporter_id == reported_user_id
    
    errors.add(:reported_user, 'No puedes reportarte a ti mismo')
  end
  
  def no_duplicate_recent_reports
    return unless reporter && reported_user
    
    recent_report = Report.where(
      reporter: reporter,
      reported_user: reported_user,
      reason: reason
    ).where('created_at > ?', 1.day.ago).exists?
    
    if recent_report
      errors.add(:base, 'Ya has reportado a este usuario por esta razón en las últimas 24 horas')
    end
  end
  
  def check_auto_ban_conditions
    CheckAutoBanConditionsJob.perform_later(reported_user)
  end
end