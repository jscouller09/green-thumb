class AddAvgTenoColumnToWeatherStations < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_stations, :avg_temp_24_hr_c, :float
  end
end
