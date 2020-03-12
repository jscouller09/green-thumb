class ConversationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # An admin can see all task of every user
      if user.admin?
        scope.all
    # Normal user can only see their own tasks
      else
        scope.where(user: user)
      end
    end
  def index?
    user.present?
  end
  end
end
