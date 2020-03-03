desc "Download Christchurch weather data using the Heroku scheduler add-on"
task :download_chc_weather_data => :environment do
  puts "Downloading data for Christchurch..."
  stn = WeatherStation.find(7910036)
  data = stn.download_current_weather
  puts "Download complete. Storing measurement in DB..."
  meas = Measurement.new(data)
  meas.weather_station = stn
  meas.save!
  puts "Done!"
end
