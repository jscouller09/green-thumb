class AddColsToWeatherAlerts < ActiveRecord::Migration[5.2]
  def change
    add_column :weather_alerts, :code, :integer
    add_column :weather_alerts, :main, :string
    add_column :weather_alerts, :description, :string
  end
end
