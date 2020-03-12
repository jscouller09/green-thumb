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
  validates :length_m, numericality: { greater_than: 0 }
  validates :length_mm, numericality: { only_integer: true,
                                        greater_than: 0,
                                        allow_nil: true }
  validates :width_m, numericality: { greater_than: 0 }
  validates :width_mm, numericality: { only_integer: true,
                                      greater_than: 0,
                                      allow_nil: true }
  validates :grid_cell_size_mm, numericality: { only_integer: true,
                                                greater_than: 0 }
  validates :x, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :y, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :rooting_depth_mm, numericality: { only_integer: true,
                                               greater_than: 0,
                                               allow_nil: true }

  #after_create :calculate_dimensions_in_mm
  after_validation :calculate_dimensions_in_mm

  def clear_wheelbarrow
    # if the plant has a negative y coordinate it is in the wheelbarrow
    self.plants.where("y IS NULL OR y < 0").destroy_all
  end

  private

  def calculate_dimensions_in_mm
    self.length_mm = (self.length_m * 1000).to_i
    self.width_mm = (self.width_m * 1000).to_i
  end
end
