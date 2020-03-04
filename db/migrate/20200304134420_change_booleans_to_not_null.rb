class ChangeBooleansToNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :admin, false
    change_column_null :users, :mentor, false
    change_column_null :tasks, :completed, false
    change_column_null :waterings, :done, false
  end
end
