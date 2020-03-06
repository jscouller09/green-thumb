class WeatherStationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        # admin can see all weather stations
        scope.all
      else
        # user can only see weather stations associated with their gardens
        # make sure to remove duplicates in-case multiple gardens in same city
        user.gardens.map { |g| g.weather_station } .uniq
      end
    end
  end

  def show?
    # only show the weather station if the current user is associated with it
    # this association is through them creating a garden
    user.admin? || record.users.include?(user)
  end
end
