class CreateUsersConversationsJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :conversations, table_name: :user_conversations
  end
end
