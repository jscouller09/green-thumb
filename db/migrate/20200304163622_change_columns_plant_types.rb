class ChangeColumnsPlantTypes < ActiveRecord::Migration[5.2]
  def change
    rename_column :plant_types, :L_ini_days, :l_ini_days
    rename_column :plant_types, :L_dev_days, :l_dev_days
    rename_column :plant_types, :L_mid_days, :l_mid_days
    rename_column :plant_types, :L_end_days, :l_end_days
  end
end
