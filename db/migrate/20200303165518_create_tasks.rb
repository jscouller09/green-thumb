class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.references :user
      t.references :plant
      t.string :description
      t.date :due_date
      t.boolean :completed, default:false
      t.string :priority

      t.timestamps
    end
  end
end
