class CreateWaterings < ActiveRecord::Migration[5.2]
  def change
    create_table :waterings do |t|
      t.references :plant
      t.boolean :done, default: false
      t.float :ammount_L, default: 0.0, null:false
      t.float :ammount_mm, default: 0.0, null:false

      t.timestamps
    end
  end
end
