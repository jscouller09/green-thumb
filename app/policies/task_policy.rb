class TaskPolicy < ApplicationPolicy
  class Scope < Scope

    def resolve
    # An admin can see all task of every user
      if user.admin?
        scope.all
    # Normal user can only see their own tasks
      else
        scope.where(user: user)
      end

    end
  end
    # only the current user can create a task.
  def create?
    user.present?
  end
    # Only and admin or the current user can update a task
  def update?
    user.admin? || record.user == user
  end
    # Same policies as update
  def destroy?
    update?
  end
    # Same policies as update
  def mark_as_complete?
    update?
  end
end
