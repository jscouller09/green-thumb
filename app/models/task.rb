class Task < ApplicationRecord
  belongs_to :user
  belongs_to :plant, optional: true


  #validations
  validates_associated :user
  validates :description, presence: true
end
