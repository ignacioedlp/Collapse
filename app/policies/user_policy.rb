class UserPolicy < ApplicationPolicy
  def index?
    user&.instance_of?(AdminUser)
  end

  def show?
    # Los usuarios pueden ver su propio perfil si no están baneados
    # Los admins pueden ver cualquier perfil
    return true if user&.instance_of?(AdminUser)
    return false if banned_user?
    
    record.id == user&.id
  end

  def edit?
    # Los usuarios pueden editar su perfil si no están baneados
    # Los admins pueden editar cualquier perfil
    return true if user&.instance_of?(AdminUser)
    return false if banned_user?
    
    record.id == user&.id
  end

  def update?
    edit?
  end

  def destroy?
    user&.instance_of?(AdminUser)
  end

  def ban?
    user&.instance_of?(AdminUser) && !record.banned?
  end

  def unban?
    user&.instance_of?(AdminUser) && record.banned?
  end

  private

  def banned_user?
    user&.instance_of?(User) && user&.banned?
  end
end

class MePolicy < ApplicationPolicy
  def show?
    return false if user&.banned?
    record.id == user&.id
  end

  def edit?
    return false if user&.banned?
    record.id == user&.id
  end
end
