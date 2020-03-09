class AddColToPlants < ActiveRecord::Migration[5.2]
  def change
    add_column :plants, :kc, :float
  end
end
