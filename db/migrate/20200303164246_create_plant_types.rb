class CreatePlantTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :plant_types do |t|
      t.string :name
      t.string :scientific_name
      t.integer :spacing_mm
      t.integer :height_mm
      t.date :earliest_plant_day
      t.string :sunshine
      t.float :kc_ini
      t.float :kc_mid
      t.float :kc_end
      t.integer :L_ini_days
      t.integer :L_dev_days
      t.integer :L_mid_days
      t.integer :L_end_days
      t.string :photo_url
      t.string :icon

      t.timestamps
    end
  end
end
