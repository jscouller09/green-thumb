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
    # Only and admin or the current user can update a task
  def update?
    user.admin? || record.plant.plot.garden.user == user
  end
    # Same policies as update
  def mark_as_complete?
    update?
  end

end
