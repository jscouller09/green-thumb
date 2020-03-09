class AddColumnToMeasurements < ActiveRecord::Migration[5.2]
  def change
    add_column :measurements, :temp_feels_like_c, :float
  end
end
