class ChangeSchema < ActiveRecord::Migration[5.2]
  def change
    rename_column :gardens, :center_x, :x
    rename_column :gardens, :center_y, :y

    remove_column :gardens, :grid_cell_size_mm
    rename_column :plots, :center_x, :x
    rename_column :plots, :center_y, :y
    add_column :plots, :grid_cell_size_mm, :integer
  end
end
