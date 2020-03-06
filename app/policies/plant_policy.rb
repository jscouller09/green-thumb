class PlantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        user.plants
      end
    end
  end

  def create?
    user.present?
  end

  def destroy?
    user.admin? || record.plot.garden.user == user
  end

  def update?
    destroy?
  end
end
