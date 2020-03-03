class Watering < ApplicationRecord
  # associations
  belongs_to :plant

  # validations
  validates_associated :plant
  validates :ammount_L, numericality: { greater_than_or_equal_to: 0 }
  validates :ammount_mm, numericality: { greater_than_or_equal_to: 0 }
end
