class CreateGardens < ActiveRecord::Migration[5.2]
  def change
    create_table :gardens do |t|
      t.references :user
      t.references :weather_station
      t.string :name
      t.string :address
      t.integer :grid_cell_size_mm
      t.integer :length_mm
      t.integer :width_mm
      t.integer :center_x
      t.integer :center_y
      t.references :climate_zone

      t.timestamps
    end
  end
end
