class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation

  #a message must have a content
  validates :content, presence: true
  validates_associated :user
  validates_associated :conversation
end
