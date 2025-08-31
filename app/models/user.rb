class User < ApplicationRecord
  # Usar bcrypt para encriptar passwords
  has_secure_password validations: false
  
  # Validaciones
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :first_name, presence: true
  validates :last_name, presence: true
  
  # Normalizar el email antes de guardarlo
  before_save :normalize_email
  
  # Scopes útiles
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :google_users, -> { where(provider: 'google') }
  scope :local_users, -> { where(provider: nil) }

  def self.ransackable_attributes(auth_object = nil)
    ["confirmed_at", "created_at", "email", "first_name", "google_id", "id", "id_value", "last_name", "password_digest", "provider", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
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
  
  def password_required?
    !google_user? && (new_record? || password.present?)
  end
end
