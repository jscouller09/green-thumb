class CreateDailySummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_summaries do |t|
      t.datetime :timestamp
      t.float :tot_rain_24_hr_mm
      t.float :tot_pet_24_hr_mm
      t.float :tot_snow_24_hr_mm
      t.float :min_temp_24_hr_c
      t.float :avg_temp_24_hr_c
      t.float :max_temp_24_hr_c
      t.float :avg_humidity_24_hr_perc
      t.float :avg_wind_speed_24_hr_mps
      t.float :avg_pressure_24_hr_hPa
      t.references :weather_station, foreign_key: true

      t.timestamps
    end
  end
end
