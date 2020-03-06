class AddDimensionColsToPlots < ActiveRecord::Migration[5.2]
  def change
    add_column :plots, :length_m, :float, null: false
    add_column :plots, :width_m, :float, null: false
  end
end
