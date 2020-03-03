class CreateMeasurements < ActiveRecord::Migration[5.2]
  def change
    create_table :measurements do |t|
      t.datetime :timestamp
      t.datetime :sunrise
      t.datetime :sunset
      t.string :timezone_UTC_offset
      t.float :temp_c
      t.integer :humidity_perc
      t.integer :pressure_hPa
      t.float :wind_speed_mps
      t.integer :wind_direction_deg
      t.integer :cloudiness_perc
      t.float :rain_1h_mm
      t.float :rain_3h_mm
      t.float :snow_1h_mm
      t.float :snow_3h_mm
      t.integer :code
      t.string :main
      t.string :description
      t.string :icon
      t.references :weather_station, null: false

      t.timestamps
    end
  end
end
