class AddBeginsColToWeatherAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_alerts, :begins, :datetime
  end
end
