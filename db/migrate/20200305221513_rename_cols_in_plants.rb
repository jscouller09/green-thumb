class RenameColsInPlants < ActiveRecord::Migration[5.2]
  def change
    rename_column :plants, :center_y, :y
    rename_column :plants, :center_x, :x
  end
end
