class ChangeTypeMeasurements < ActiveRecord::Migration[5.2]
  def change
    change_column :measurements, :timezone_UTC_offset, :integer, using: '"timezone_UTC_offset"::integer'
  end
end
