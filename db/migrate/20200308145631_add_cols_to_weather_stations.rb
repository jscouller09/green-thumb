class AddColsToWeatherStations < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_stations, :elevation_m, :integer
    add_column :weather_stations, :tot_rain_24hr_mm, :float
    add_column :weather_stations, :tot_pet_24_hr_mm, :float
    add_column :weather_stations, :min_temp_24_hr_c, :float
    add_column :weather_stations, :max_temp_24_hr_c, :float
    add_column :weather_stations, :avg_humidity_24_hr_perc, :float
    add_column :weather_stations, :avg_wind_speed_24_hr_mps, :float
    add_column :weather_stations, :avg_pressure_24_hr_hPa, :float
  end
end
