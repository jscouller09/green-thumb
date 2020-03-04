class UpdateClimateZonesColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :climate_zones, :zone_number, :zone
    add_column :climate_zones, :hemisphere, :string
  end
end
