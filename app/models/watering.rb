class Watering < ApplicationRecord
  # associations
  belongs_to :plant

  # validations
  validates_associated :plant
  validates :ammount_L, numericality: { greater_than_or_equal_to: 0 }
  validates :ammount_mm, numericality: { greater_than_or_equal_to: 0 }

  def update_plant_water_deficit
    # this will be called from a particular watering instance
    # assume it is only called when a watering is marked as done
    # run when watering is completed to update plant water deficit
    self.plant.water_deficit_mm = [self.plant.water_deficit_mm - self.ammount_mm, 0.0].max
    self.plant.save
  end
end
