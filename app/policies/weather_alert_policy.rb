class WeatherAlertPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # user can only have access to their own weather_alert
        user.weather_alerts
      end
    end
  end

  def mark_as_dismissed?
    user.admin? || record.user==user
  end
end
