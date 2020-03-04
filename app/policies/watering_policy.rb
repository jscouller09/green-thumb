class WateringPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
        # An admin can see all waterings of every user
      if user.admin?
        scope.all
        # Normal user can only see their own waterings
      else
        scope.where(user: user)
      end
    end
  end
  # only the current user can see his watering board.
  def index?
    user.present?
  end

  def show?
    user.present?
  end
    # Only and admin or the current user can update a task
  def update?
    user.admin? || record.user == user
  end
    # Same policies as update
  def mark_as_complete?
    update?
  end
end
