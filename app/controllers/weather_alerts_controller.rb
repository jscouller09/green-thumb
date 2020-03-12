class WeatherAlertsController < ApplicationController

  def mark_as_dismissed
    # @weather_alert = WeatherAlert.find(params[:id])
    @station = WeatherStation.find(params[:weather_station_id])
    authorize @station
    @station.weather_alerts.update_all(dismissed: true)
    # @weather_alert.update(dismissed: true)
    redirect_to weather_station_path(@station)
    end
end
