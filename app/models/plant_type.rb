class PlantType < ApplicationRecord
  #associations
  has_many :plants, dependent: :destroy

  #a plant type as a name
  validates :name, presence: true

  # a plant type spacing can only be an integer > 0
  validates :spacing_mm, numericality: { only_integer: true, greater_than: 0 }
  validates :height_mm, numericality: { only_integer: true, greater_than: 0 }

  # a plant type kc is a float greater or = to 0 (note default is set at 1.0)
  validates :kc_ini, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :kc_mid, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :kc_end, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  # a plant type L days can only be integer and > 0
  validates :l_ini_days, numericality: { only_integer: true, greater_than: 0 }
  validates :l_dev_days, numericality: { only_integer: true, greater_than: 0 }
  validates :l_mid_days, numericality: { only_integer: true, greater_than: 0 }
  validates :l_end_days, numericality: { only_integer: true, greater_than: 0 }

end
