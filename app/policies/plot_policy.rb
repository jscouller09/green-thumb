class PlotPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
        # An admin can see all plots of every user
      if user.admin?
        scope.all
        # Normal user can only see their own plots
      else
        # the User can see only the first garden for now but later maybe more
        user.gardens.first.plots
      end
    end
  end
  # GET /gardens/:garden_id/plots/new
  def new?
  end

  # POST  /gardens/:garden_id/plots/
  def create?
  end

  # GET /plots/:id/edit
  def edit?
  end
  # PATCH /plots/:id/
  def update?
    user.admin? || record.user == user
  end

  # DELETE  /plots/:id
  def destroy?
  end

  # PATCH plots/:id/complete_waterings
  def complete_watering?
  end
end
