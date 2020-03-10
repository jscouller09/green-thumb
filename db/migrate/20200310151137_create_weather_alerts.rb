class CreateWeatherAlerts < ActiveRecord::Migration[5.2]
  def change
    create_table :weather_alerts do |t|
      t.string :message
      t.boolean :dismissed, default: false
      t.datetime :apply_until
      t.timestamps
    end
  end
end
