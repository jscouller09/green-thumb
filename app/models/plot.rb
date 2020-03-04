class Plot < ApplicationRecord
  # associations
  belongs_to :garden
  has_many :plants, dependent: :destroy
  has_many :waterings, through: :plants
  has_many :plant_types, through: :plants
  has_many :tasks, through: :plants

  # validations
  validates_associated :garden
  validates :name, presence: true
  validates :shape, inclusion: { in: %w(rectangle circle),
                                 message: "%{value} is not a valid shape" }
  validates :length_mm, numericality: { only_integer: true,
                                        greater_than: 0 }
  validates :width_mm, numericality: { only_integer: true,
                                       greater_than: 0 }
  validates :center_x, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :center_y, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :rooting_depth_mm, numericality: { only_integer: true,
                                               greater_than: 0,
                                               allow_nil: true }
end
