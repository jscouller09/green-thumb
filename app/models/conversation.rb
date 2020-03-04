class Conversation < ApplicationRecord
  has_many :user_conversations, dependent: :destroy
  has_many :messages, through: :user_conversations
end
