class HourlyUpdatesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # get hourly measurements and forecast updates
    puts "Starting hourly tasks at #{DateTime.now}..."
    ActiveRecord::Base.logger.level = 1
    WeatherStation.all.each do |station|
      print "\tQuerying #{station.name}..."
      # get current data
      data = station.download_current_weather
      # save measurement
      meas = Measurement.new(data)
      meas.weather_station = station
      print "meas-saved:#{meas.save}..."
      # check forecast for alerts
      any_alerts = station.check_forecast_for_alerts
      print "any-alerts:#{any_alerts}..."
      puts "done!"
    end
    ActiveRecord::Base.logger.level = 0
    puts "Finished hourly tasks at #{DateTime.now}!"
  end
end
