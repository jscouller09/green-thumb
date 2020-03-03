class CreateClimateZones < ActiveRecord::Migration[5.2]
  def change
    create_table :climate_zones do |t|
      t.string :zone_number
      t.integer :growing_season_days
      t.date :start_of_growing_season

      t.timestamps
    end
  end
end
