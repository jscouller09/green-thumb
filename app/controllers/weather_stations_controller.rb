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
      redirect_to weather_station_path(@weather_stations.first)
    end
  end


  #GET  /weather_stations/:id
  def show
    alert_messages = []
    active_alerts = policy_scope(WeatherAlert).where("dismissed = ? AND apply_until >= ?", false, DateTime.now())
    active_alerts.each do |alert|
      alert_messages << alert.message
    end
    @alerts = alert_messages.join("&nbsp&nbsp&nbsp&nbsp&nbsp")

    @station = WeatherStation.find(params[:id])
    authorize @station
    # get the current weather and forecast summary
    weather = @station.weather_summary
    # unpack current weather and forecast
    @current = weather[:now]
    # store current weather as a measurement instance
    meas = Measurement.new(@current)
    meas.weather_station =  @station
    meas.save
    # note forecast shown is only next 3 days (excluding today)
    # could change later so forecast for remainder of today is shown also?
    @forecast = {}
    for i in 1..3 do
      current_d = (weather[:today] + i).strftime('%A')
      @forecast[current_d] = weather[current_d]
    end
  end
end
