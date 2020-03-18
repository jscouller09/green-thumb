class AddSnowToWeatherStations < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_stations, :tot_snow_24_hr_mm, :float
  end
end
