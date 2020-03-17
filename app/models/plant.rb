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


  def check_planted_status
    # only run if we have a specified plant date and the plant is not planted
    unless self.plant_date.nil? || self.planted
      # plants with plant dates before today are automatically planted
      self.update(planted: self.plant_date < Date.today)
    end
  end

  def generate_watering
    # only run if the plant is planted and we have a plant date
    if self.plant_date && self.planted
      # if water deficit exceeds 2 mm and it is not snowing, generate a watering
      if self.water_deficit_mm > 2.0 && self.plot.garden.weather_station.tot_snow_24_hr_mm == 0.0
        # assume maximum watering per event is 20.0 mm for drainage reasons
        mm_irrig = [self.water_deficit_mm, 20.0].min
        # first check if there is already an incomplete watering we want to add to
        if self.waterings.where(done: false).first
          # add to previous watering
          water = self.waterings.where(done: false).first
          water.ammount_mm += mm_irrig
          water.ammount_L = (water.ammount_mm * Math::PI * self.radius_mm**2)/1e6
          return water.save
        else
          # generate new watering
          water = Watering.new(ammount_mm: mm_irrig,
                               ammount_L: (mm_irrig * Math::PI * self.radius_mm**2)/1e6)
          water.plant = self
          return water.save
        end
      else
        return false
      end
    else
      return false
    end
  end

  def update_water_deficit
    # only run if the plant is planted and we have a plant date
    if self.plant_date && self.planted
      # get weather station pet and convert to crop et
      self.et_mm = self.kc * self.plot.garden.weather_station.tot_pet_24_hr_mm
      # calculate water deficit
      self.water_deficit_mm -= (self.plot.garden.weather_station.tot_rain_24_hr_mm - self.et_mm)
      return self.save
    else
      return false
    end
  end

  def update_crop_coeff
    # only run if the plant is planted and we have a plant date
    if self.plant_date && self.planted
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
        self.kc = self.plant_type.kc_end
      end
      return self.save
    else
      return false
    end
  end

  def plant_life_days
    # total days for plant life cycle
    self.plant_type.l_ini_days + self.plant_type.l_dev_days + self.plant_type.l_mid_days + self.plant_type.l_end_days
  end

  def plant_age_days
    # plant age
    (Date.today - self.plant_date).to_i
  end

  private

  def add_radius
    self.update(radius_mm: self.plant_type.spacing_mm / 2)
  end
end
