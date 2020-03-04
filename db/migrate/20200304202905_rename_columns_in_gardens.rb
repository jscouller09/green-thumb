class RenameColumnsInGardens < ActiveRecord::Migration[5.2]
  def change
    rename_column :gardens, :latitude, :lat
    rename_column :gardens, :longitude, :lon
  end
end
