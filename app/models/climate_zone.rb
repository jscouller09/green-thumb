class ClimateZone < ApplicationRecord
  # associations
  has_many :gardens

  # validations
  validates :zone, presence: true
  validates :hemisphere, inclusion: { in: %w(southern northern),
                                      message: "%{value} is not a valid hemisphere" }
  validates :growing_season_days, numericality: { only_integer: true,
                                                  greater_than_or_equal_to: 0 }
end
