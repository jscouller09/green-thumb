desc "All tasks that need to be run once per hour"
task :hourly_tasks => :environment do
  puts "Running hourly tasks...."
  # current weather download and creation of measurements
  Rake::Task["weather:download_current"].invoke
  # forecast download and creation of any alerts
  Rake::Task["weather:check_forecast"].invoke
  puts "Done!"
end

desc "All tasks that need to be run once per day"
task :daily_tasks => :environment do
  puts "Running daily tasks...."
  # summarize weather for last 24 hrs and calculate PET
  Rake::Task["weather:summarize_last_24hrs"].invoke
  # updated planted status
  Rake::Task["plants:check_planted"].invoke
  # generate waterings
  Rake::Task["plants:calculate_water_requirements"].invoke
  puts "Done!"
end

## PLANTS
namespace :plants do
  desc "update the crop coefficient/water deficit/waterings for each plant in the DB"
  task :calculate_water_requirements => :environment do
    puts "Calculating plant water requirements..."
    Plant.all.each do |plant|
      status1 = plant.update_crop_coeff
      status2 = plant.update_water_deficit
      status3 = plant.generate_watering
      puts "\tPlant ID #{plant.id}: crop-coeff...#{status1} water-deficit...#{status2} watering...#{status3}"
    end
    puts "Done!"
  end

  desc "for each plant in the DB, update planted status if the plant date is before today"
  task :check_planted => :environment do
    puts "Checking if plants have been planted..."
    Plant.all.each do |plant|
      plant.check_planted_status
    end
    puts "Done!"
  end
end

## WEATHER
namespace :weather do
  desc "download current weather data for each weather station in the DB and create measurement instances"
  task :download_current => :environment do
    puts "Downloading weather data and storing measurements..."
    WeatherStation.all.each do |station|
      print "\tQuerying #{station.name}... "
      data = station.download_current_weather
      meas = Measurement.new(data)
      meas.weather_station = station
      puts "downloaded-ok...#{meas.save}"
    end
    puts "Done!"
  end

  desc "download forecast for each weather station in the DB and check if any alerts need to be generated"
  task :check_forecast => :environment do
    puts "Downloading forecast and generating alerts..."
    WeatherStation.all.each do |station|
      print "\tQuerying #{station.name}... "
      any_alerts = station.check_forecast_for_alerts
      puts "any-alerts...#{any_alerts}"
    end
    puts "Done!"
  end

  desc "once per day summarize the last 24hrs of weather measurements for each weather station in the DB"
  task :summarize_last_24hrs => :environment do
    puts "Summarizing weather for last 24 hrs..."
    WeatherStation.all.each do |station|
      print "\tWorking on #{station.name}... "
      # update stats then calculate PET
      status1 = station.calculate_24hr_stats
      status2 = station.calculate_24hr_pet
      puts "calculate_24hr_stats...#{status1} calculate_24hr_pet...#{status2}"
    end
    puts "Done!"
  end
end

## EXPORTING DB
namespace :db do
  desc "export the DB to csv files for quicker re-seeding"
  task :export => :environment do
    puts "Exporting data..."
    # generate csvs for different models (except for users b/c of password security)
    puts "Exporting weather stations..."
    export_model_to_csv(WeatherStation, 'export_weather_stations.csv')
    puts "Exporting measurements..."
    export_model_to_csv(Measurement, 'export_measurements.csv')
    puts "Export weather alerts..."
    export_model_to_csv(WeatherAlert, 'export_weather_alerts.csv')
    puts "Exporting climate zones..."
    export_model_to_csv(ClimateZone, 'export_climate_zones.csv')
    puts "Exporting gardens..."
    export_model_to_csv(Garden, 'export_gardens.csv')
    puts "Exporting plots..."
    export_model_to_csv(Plot, 'export_plots.csv')
    puts "Exporting plant_types..."
    export_model_to_csv(PlantType, 'export_plant_types.csv')
    puts "Export plants..."
    # make sure to not export plants in the wheelbarrow area of a plot
    Plot.all.each { |plot| plot.clear_wheelbarrow }
    export_model_to_csv(Plant, 'export_plants.csv')
    puts "Export tasks..."
    export_model_to_csv(Task, 'export_tasks.csv')
    puts "Export waterings..."
    export_model_to_csv(Watering, 'export_waterings.csv')
  end
end

# supporting code for exporting DB to CSV
require 'csv'

def export_model_to_csv(model_class, csv_file)
  csv_options = { col_sep: ',',
                  quote_char: '"',
                  headers: :first_row,
                  converters: :numeric,
                  header_converters: lambda { |h| h.to_sym }
                }
  CSV.open(File.join(Dir.pwd, "db", csv_file), "wb", csv_options) do |csv|
    model_class.all.each_with_index do |instance, i|
      if i == 0
        headers = instance.attributes.keys.to_a
        csv << headers
      end
      csv << instance.attributes.values.to_a
    end
  end
end
