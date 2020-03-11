# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

def generate_model_from_csv(model_class, csv_file)
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
end

# generate seeds for different models
generate_model_from_csv(WeatherStation, 'weather_stations.csv')
generate_model_from_csv(User, 'users.csv')
generate_model_from_csv(ClimateZone, 'climate_zones.csv')
generate_model_from_csv(Garden, 'gardens.csv')
generate_model_from_csv(Plot, 'plots.csv')
generate_model_from_csv(PlantType, 'plant_types.csv')
generate_model_from_csv(Plant, 'plants.csv')
generate_model_from_csv(Task, 'tasks.csv')
generate_model_from_csv(Watering, 'waterings.csv')
generate_model_from_csv(WeatherAlert, 'weather_alerts.csv')
