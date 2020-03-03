class Conversation < ApplicationRecord
  has_many :messages
  has_many :user_conversations
  has_many :messages, through: :user_conversations
end
