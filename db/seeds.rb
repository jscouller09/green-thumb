# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

def generate_model_from_csv(model_class, csv_file, table_name)
  csv_options = { col_sep: ',',
                  quote_char: '"',
                  headers: :first_row,
                  converters: :numeric,
                  header_converters: lambda { |h| h.to_sym }
                }
  CSV.read("db/#{csv_file}", csv_options).each_with_index do |row, i|
    # grab all columns and generate instance of the model
    args = row.to_h
    model = model_class.new(args)
    begin
      valid = model.save
    rescue ActiveRecord::RecordNotUnique
      puts "Couldn't create row #{i+1} from #{csv_file}. Already in DB!"
    else
      unless valid
        puts "Couldn't create row #{i+1} from #{csv_file}. Validation error?"
        model.errors.messages.each { |k, v| puts "\t#{k}: #{v}"}
      else
        puts "Made model for row #{i+1} from #{csv_file}."
      end
    end
  end
  # reset the autoincrement incase we have specified ID's
  last_id = model_class.last.id
  #ActiveRecord::Base.connection.execute("ALTER TABLE #{table_name} AUTO_INCREMENT = #{last_id + 1};")
  model_class.connection.execute("ALTER SEQUENCE #{table_name}_id_seq RESTART WITH #{last_id + 1};")
end

# generate seeds for different models
# generate_model_from_csv(WeatherStation, 'weather_stations.csv', 'weather_stations')
# generate_model_from_csv(User, 'users.csv', 'users')
# generate_model_from_csv(ClimateZone, 'climate_zones.csv', 'climate_zones')
# generate_model_from_csv(Garden, 'gardens.csv', 'gardens')
# generate_model_from_csv(Plot, 'plots.csv', 'plots')
# generate_model_from_csv(PlantType, 'plant_types.csv', 'plant_types')
# generate_model_from_csv(Plant, 'plants.csv', 'plants')
# generate_model_from_csv(Task, 'tasks.csv', 'tasks')
# generate_model_from_csv(Watering, 'waterings.csv', 'waterings')
# generate_model_from_csv(WeatherAlert, 'weather_alerts.csv', 'weather_alerts')

# generate_model_from_csv(User, 'users.csv', 'users')
# generate_model_from_csv(WeatherStation, 'export_weather_stations.csv', 'weather_stations')
# generate_model_from_csv(Measurement, 'export_measurements.csv', 'measurements')
# generate_model_from_csv(ClimateZone, 'export_climate_zones.csv', 'climate_zones')
# generate_model_from_csv(Garden, 'export_gardens.csv', 'gardens')
# generate_model_from_csv(Plot, 'export_plots.csv', 'plots')
# generate_model_from_csv(PlantType, 'export_plant_types.csv', 'plant_types')
# generate_model_from_csv(Plant, 'export_plants.csv', 'plants')
# generate_model_from_csv(Task, 'export_tasks.csv', 'tasks')
generate_model_from_csv(Watering, 'export_waterings.csv', 'waterings')
# generate_model_from_csv(WeatherAlert, 'export_weather_alerts.csv', 'weather_alerts')
