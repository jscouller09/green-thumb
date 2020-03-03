class ClimateZone < ApplicationRecord
  # associations
  has_many :gardens

  # validations
  validates :zone_number, presence: true
  validates :growing_season_days, numericality: { only_integer: true,
                                                  greater_than_or_equal_to: 0 }
end
