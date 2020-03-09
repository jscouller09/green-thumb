class AddTimestampToWeatherStations < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_stations, :timestamp, :datetime
  end
end
