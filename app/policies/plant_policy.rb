class PlantPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
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
