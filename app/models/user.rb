class User < ApplicationRecord
  # Usar bcrypt para encriptar passwords
  has_secure_password

  # Configuración de roles con Rolify para roles simples
  rolify

  # Relaciones para el sistema de baneos
  belongs_to :banned_by, class_name: 'AdminUser', optional: true

  # Validaciones
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Normalizar el email antes de guardarlo
  before_save :normalize_email

  # Asignar rol 'user' por defecto después de crear el usuario
  after_create :assign_default_role

  # Scopes útiles
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :google_users, -> { where(provider: 'google') }
  scope :local_users, -> { where(provider: nil) }
  
  # Scopes para baneos
  scope :banned, -> { where.not(banned_at: nil) }
  scope :not_banned, -> { where(banned_at: nil) }
  scope :permanently_banned, -> { banned.where(banned_until: nil) }
  scope :temporarily_banned, -> { banned.where.not(banned_until: nil) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[confirmed_at created_at email first_name google_id id id_value last_name
      password_digest provider updated_at banned_at banned_reason banned_until]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  # Métodos de instancia
  def full_name
    "#{first_name} #{last_name}".strip
  end

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current)
  end

  def google_user?
    provider == 'google'
  end

  # Métodos para el sistema de baneos
  def banned?
    return false if banned_at.nil?
    return true if banned_until.nil? # Baneo permanente
    
    banned_until > Time.current # Baneo temporal aún vigente
  end

  def ban!(reason:, admin_user:, until_date: nil)
    update!(
      banned_at: Time.current,
      banned_reason: reason,
      banned_by: admin_user,
      banned_until: until_date
    )
  end

  def unban!(admin_user: nil)
    update!(
      banned_at: nil,
      banned_reason: nil,
      banned_by: nil,
      banned_until: nil
    )
  end

  def ban_status
    return 'activo' unless banned?
    return 'baneado permanentemente' if banned_until.nil?
    
    "baneado hasta #{banned_until.strftime('%d/%m/%Y %H:%M')}"
  end

  def ban_expired?
    return false if banned_at.nil?
    return false if banned_until.nil? # Baneo permanente
    
    banned_until <= Time.current
  end

  # Método para autenticación con Google
  def self.from_google(google_user_info)
    user = find_or_initialize_by(email: google_user_info['email'])

    if user.new_record?
      user.assign_attributes(
        first_name: google_user_info['given_name'],
        last_name: google_user_info['family_name'],
        google_id: google_user_info['sub'],
        provider: 'google',
        confirmed_at: Time.current
      )
      user.save!
      # El callback after_create se ejecutará automáticamente
    elsif !user.google_user?
      # Vincular cuenta existente con Google
      user.update!(
        google_id: google_user_info['sub'],
        provider: 'google'
      )
    end

    user
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def assign_default_role
    # Asignar rol 'user' por defecto si no tiene roles
    return if has_role?(:user)

    user_role = Role.find_by(name: 'user')
    if user_role
      add_role(user_role)
      Rails.logger.info "Rol 'user' asignado automáticamente a #{email}"
    else
      Rails.logger.warn "Rol 'user' no encontrado en la base de datos"
    end
  end

  def password_required?
    !google_user? && (new_record? || password.present?)
  end

  # Métodos de autorización
  def owner?
    has_role?(:owner)
  end

  def moderator?
    has_role?(:moderator)
  end

  def user?
    has_role?(:user) || roles.empty?
  end

  def have_role?(role)
    has_role?(role)
  end
end
