class RenameTotRainColInWeatherStations < ActiveRecord::Migration[5.2]
  def change
    rename_column :weather_stations, :tot_rain_24hr_mm, :tot_rain_24_hr_mm
  end
end
