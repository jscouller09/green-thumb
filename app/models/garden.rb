class Garden < ApplicationRecord
  # associations
  belongs_to: weather_station
  belongs_to: climate_zone
  belongs_to: user
  has_many: plots, dependent: :destroy
  has_many: plants, through: :plots
  has_many: waterings, through: :plants
  has_many: plant_types, through: :plants
  has_many: tasks, through: :plants

  # validations
  validates_associated: weather_station
  validates :name, presence: true
  validates :address, presence: true,
  validates :grid_cell_size_mm, numericality: { only_integer: true,
                                                greater_than: 0 }
  validates :length_mm, numericality: { only_integer: true,
                                        greater_than: 0 }
  validates :width_mm, numericality: { only_integer: true,
                                       greater_than: 0 }
  validates :center_x, numericality: { only_integer: true,
                                       allow_nil: true }
  validates :center_y, numericality: { only_integer: true,
                                       allow_nil: true }
end
