# Modelo para usuarios administradores del panel ActiveAdmin
class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
    :recoverable, :rememberable, :validatable

  # Validaciones
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Normalizar email antes de guardar
  before_save :normalize_email

  # Relaciones
  has_many :banned_users, class_name: 'User', foreign_key: 'banned_by_id', dependent: :nullify
  has_many :ban_logs, dependent: :destroy

  # Scopes
  scope :active, -> { where(active: true) }

  # Métodos de instancia
  def display_name
    email
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :inactive
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
