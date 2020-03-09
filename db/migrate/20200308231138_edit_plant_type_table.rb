class EditPlantTypeTable < ActiveRecord::Migration[5.2]
  def change
    add_column :plant_types, :description, :text
    add_column :plant_types, :photo_bg, :string
  end
end
