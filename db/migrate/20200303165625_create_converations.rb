class CreateConverations < ActiveRecord::Migration[5.2]
  def change
    create_table :converations do |t|

      t.timestamps
    end
  end
end
