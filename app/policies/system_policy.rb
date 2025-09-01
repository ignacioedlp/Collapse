class SystemPolicy < ApplicationPolicy
  def info?
    true # Información del sistema es pública
  end
end
