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
    user.admin? || record.garden.user == user
  end

  # DELETE  /plots/:id
  def destroy?
  end
  # This method is in the waterings controller
  def watering_plot?
    update?
  end
end
