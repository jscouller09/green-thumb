class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation

  #a message must have a content
  validates :content, presence: true
end
