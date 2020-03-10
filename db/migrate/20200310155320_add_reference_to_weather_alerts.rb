class AddReferenceToWeatherAlerts < ActiveRecord::Migration[5.2]
  def change
    add_reference :weather_alerts, :weather_station, foreign_key: true
  end
end
