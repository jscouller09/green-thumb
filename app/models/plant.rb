class Plant < ApplicationRecord
  # associations
  belongs_to :plot
  has_many :tasks
  belongs_to :plant_type

  # validations
  validates_associated :plant_type
  validates_associated :plot
  validates :radius_mm, numericality: { only_integer: true,
                                        greater_than: 0 }
  validates :center_x, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :center_y, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :water_deficit_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :plant_date, presence: true
end