class WateringPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
        # An admin can see all waterings of every user
      if user.admin?
        scope.all
        # Normal user can only see their own waterings
      else
        # the User can see only the first garden for now but later maybe more
        user.gardens.first.waterings
      end
    end
  end
  # only the current user can see his watering board.
  def watering_overview?
    user.present?
  end

  def watering_plot?
    user.present?
  end
    # Only and admin or the current user can update a task
  def update?
    user.admin? || user.present?
  end
    # Same policies as update
  def mark_as_complete?
    update?
  end
end
