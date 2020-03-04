class GardenPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    # users can only see their own gardens
    user.admin? || record.user == user
  end

  # note new will apply same authorization as create by default
  def create?
    # anyone can create a new garden if they are logged in
    user.present?
  end
end
