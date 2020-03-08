class Plant < ApplicationRecord
  # associations
  belongs_to :plot
  has_many :tasks, dependent: :destroy
  has_many :waterings, dependent: :destroy
  belongs_to :plant_type

  # validations
  validates_associated :plant_type
  validates_associated :plot
  validates :radius_mm, numericality: { only_integer: true,
                                        greater_than: 0,
                                        allow_nil: true }
  validates :x, numericality: { only_integer: true,
                                allow_nil: true }
  validates :y, numericality: { only_integer: true,
                                allow_nil: true }
  validates :water_deficit_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :plant_date, presence: true

  after_create :add_radius

  def update_water_deficit
    # get weather station pet and convert to crop et
    self.et_mm = self.kc * self.plot.garden.weather_station.tot_pet_24_hr_mm
    # calculate water deficit
    self.water_deficit_mm -= (self.plot.garden.weather_station.tot_rain_24_hr_mm - self.et_mm)
    self.save
  end

  def update_crop_coeff
    # calculate the crop coefficient based on age of plant
    # see graph at bottom of http://www.fao.org/3/X0490E/x0490e0b.htm#TopOfPage
    if plant_age_days <= self.plant_type.l_ini_days
      # inital plant growth
      self.kc = self.plant_type.kc_ini
    elsif plant_age_days > self.plant_type.l_ini_days && plant_age_days <= (self.plant_type.l_dev_days + self.plant_type.l_ini_days)
      # interpolate linearly during development stage
      perc = (plant_age_days - self.plant_type.l_ini_days) / self.plant_type.l_dev_days
      kc = (self.plant_type.kc_mid - self.plant_type.kc_ini) * perc
      self.kc = kc + self.plant_type.kc_ini
    elsif plant_age_days > (self.plant_type.l_dev_days + self.plant_type.l_ini_days) && plant_age_days <= (self.plant_type.l_mid_days + self.plant_type.l_dev_days + self.plant_type.l_ini_days)
      # mid season stage
      self.kc = self.plant_type.kc_mid
    elsif plant_age_days > (self.plant_type.l_mid_days + self.plant_type.l_dev_days + self.plant_type.l_ini_days) && plant_age_days <= plant_life_days
      # interpolate linearly during late season stage
      perc = (plant_age_days - self.plant_type.l_mid_days - self.plant_type.l_dev_days - self.plant_type.l_ini_days) / self.plant_type.l_end_days
      kc = (self.plant_type.kc_end - self.plant_type.kc_mid) * perc
      self.kc = self.plant_type.kc_mid + kc
    else
      self.kc = kc_end
    end
    self.save
  end

  def plant_life_days
    # total days for plant life cycle
    self.plant_type.l_ini_days + self.plant_type.l_dev_days + self.plant_type.l_mid_days + self.plant_type.l_end_days
  end

  def plant_age_days
    # plant age
    [(Date.today - self.plant_date).to_i].max
  end

  private

  def add_radius
    self.update(radius_mm: self.plant_type.spacing_mm / 2)
  end
end
