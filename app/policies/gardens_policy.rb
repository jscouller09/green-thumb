class GardenPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  # note new will apply same authorization as create by default
  def create?
    # anyone can create a new garden if they are logged in
    user.present?
  end
end
