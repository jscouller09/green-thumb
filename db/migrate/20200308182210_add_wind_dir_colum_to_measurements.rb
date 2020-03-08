class AddWindDirColumToMeasurements < ActiveRecord::Migration[5.2]
  def change
    add_column :measurements, :wind_direction, :string
  end
end
