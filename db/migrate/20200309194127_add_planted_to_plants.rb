class AddPlantedToPlants < ActiveRecord::Migration[5.2]
  def change
    add_column :plants, :planted, :boolean, default: false, null: false
  end
end
