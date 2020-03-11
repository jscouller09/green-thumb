namespace :plants do
  desc "once per day update the crop coefficient/water deficit/waterings for each plant in the DB"
  task :calculate_water_requirements => :environment do
    puts "Calculating plant water requirements..."
    Plant.all.each do |plant|
      plant.update_crop_coeff
      plant.update_water_deficit
      plant.generate_watering
    end
    puts "Done!"
  end

  desc "once per day check if plants have been planted"
  task :check_plants_planted => :environment do
    puts "Checking if plants have been planted..."
    Plant.all.each do |plant|
      plant.check_planted_status
    end
    puts "Done!"
  end

end

namespace :weather do
  desc "every hour download current weather data for each weather station in the DB"
  task :download_hourly_weather_data => :environment do
    puts "Downloading weather data and storing measurements..."
    WeatherStation.all.each do |station|
      data = station.download_current_weather
      meas = Measurement.new(data)
      meas.weather_station = station
      meas.save!
      # also update the stats
      station.calculate_24hr_stats
    end
    puts "Done!"
  end

  desc "once per day summarize the last 24hrs of weather measurements for each weather station in the DB"
  task :summarize_daily_weather => :environment do
    puts "Summarizing weather for last 24 hrs..."
    WeatherStation.all.each do |station|
      # update stats then calculate PET
      station.calculate_24hr_stats
      station.calculate_24hr_pet
    end
    puts "Done!"
  end
end
