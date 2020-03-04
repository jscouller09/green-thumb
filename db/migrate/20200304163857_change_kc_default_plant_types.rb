class ChangeKcDefaultPlantTypes < ActiveRecord::Migration[5.2]
  def change
    change_column_default :plant_types, :kc_ini, 1.0
    change_column_default :plant_types, :kc_mid, 1.0
    change_column_default :plant_types, :kc_end, 1.0
  end
end
