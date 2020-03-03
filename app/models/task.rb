class Task < ApplicationRecord
  belongs_to :user
  belongs_to :plant


  #validations
  validates_associated :user
  validates :description, presence: true
end
