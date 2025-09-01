class Role < ApplicationRecord
  # Configuración de Rolify para roles simples (no polimórficos)
  rolify
  
  # Validaciones
  validates :name, presence: true, uniqueness: true
  
  # Relaciones
  has_and_belongs_to_many :users, join_table: :users_roles
  
  # Scopes útiles
  scope :by_name, ->(name) { where(name: name) }
  
  # Métodos de instancia
  def display_name
    name.humanize
  end
  
  def to_s
    name
  end
  
  # Métodos de clase para roles comunes
  def self.owner
    find_by(name: 'owner')
  end
  
  def self.moderator
    find_by(name: 'moderator')
  end
  
  def self.user
    find_by(name: 'user')
  end
  
  # Verificar si un rol existe por nombre
  def self.exists_by_name?(name)
    where(name: name).exists?
  end
end
