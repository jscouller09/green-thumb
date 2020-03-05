class PlotPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.plots
      end
    end
  end

  def show?
    user.admin? || record.garden.user == user
  end

  def create?
    user.present?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
