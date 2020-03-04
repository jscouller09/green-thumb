class TaskPolicy < ApplicationPolicy
  class Scope < Scope

    def resolve
    # an admin can see all task of every user
      if user.admin?
        scope.all
    # normal user can only see their own tasks
      else
        scope.where(user: user)
      end

    end
  end

  def create?
    user.present?
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    update?
  end

  def mark_as_complete?
    update?
  end
end
