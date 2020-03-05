class WeatherStationsController < ApplicationController

  #GET  /weather_stations
  def index
    # first get the current users gardens
    @weather_stations = policy_scope(WeatherStation)
    if @weather_stations.empty?
      # no garden and no weather station associated, redirect to garden new page
      redirect_to gardens_path
    elsif @weather_stations.length > 1
      # user has many gardens, get them to choose which weather station
      render :index
    else
      # user has 1 garden, go to show page for the associated weather station
      redirect_to weather_station_path(weather_stations.first)
    end
  end


  #GET  /weather_stations/:id
  def show
    @station = WeatherStation.find(params[:id])
    authorize @station
    # get the current weather and forecast summary
    @weather = @station.weather_summary
    binding.pry
  end
end
