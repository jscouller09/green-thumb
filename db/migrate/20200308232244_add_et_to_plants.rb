class AddEtToPlants < ActiveRecord::Migration[5.2]
  def change
    add_column :plants, :et_mm, :float
  end
end
