class ChangeElevationColumnInWeatherStations < ActiveRecord::Migration[5.2]
  def change
    change_column :weather_stations, :elevation_m, :float
  end
end
