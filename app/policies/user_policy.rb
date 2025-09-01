class MePolicy < ApplicationPolicy
  def show?
    record.id == user.id
  end

  def edit?
    record.id == user.id
  end
end
