class CreatePlots < ActiveRecord::Migration[5.2]
  def change
    create_table :plots do |t|
      t.references :garden
      t.string :name
      t.string :shape
      t.integer :length_mm
      t.integer :width_mm
      t.integer :center_x
      t.integer :center_y
      t.string :shady_spots
      t.integer :rooting_depth_mm
      t.string :soil_type

      t.timestamps
    end
  end
end
