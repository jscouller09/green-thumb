class CreatePlants < ActiveRecord::Migration[5.2]
  def change
    create_table :plants do |t|
      t.references :plot
      t.references :plant_type
      t.integer :center_x
      t.integer :center_y
      t.integer :radius_mm
      t.date :plant_date
      t.float :water_deficit_mm

      t.timestamps
    end
  end
end
