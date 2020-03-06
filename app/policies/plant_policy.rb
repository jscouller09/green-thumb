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

  # DELETE  /plants/:id
  def destroy?
    user.admin? || record.plot.garden.user == user
  end
end
