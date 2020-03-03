class CreateWeatherStations < ActiveRecord::Migration[5.2]
  def change
    create_table :weather_stations do |t|
      t.string :name
      t.string :country
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
