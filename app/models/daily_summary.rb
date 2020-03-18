class DailySummary < ApplicationRecord
  belongs_to :weather_station
  has_many :measurements

  validates :tot_rain_24_hr_mm,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :tot_snow_24_hr_mm,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :tot_pet_24_hr_mm,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :min_temp_24_hr_c,
            numericality: { allow_nil: true }
  validates :max_temp_24_hr_c,
            numericality: { allow_nil: true }
  validates :avg_humidity_24_hr_perc,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :avg_wind_speed_24_hr_mps,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }
  validates :avg_pressure_24_hr_hPa,
            numericality: { allow_nil: true, greater_than_or_equal_to: 0.0 }

  after_create :get_meas

  def get_meas
    self.timestamp = self.weather_station.timestamp
    self.tot_rain_24_hr_mm = self.weather_station.tot_rain_24_hr_mm
    self.tot_pet_24_hr_mm = self.weather_station.tot_pet_24_hr_mm
    self.tot_snow_24_hr_mm = self.weather_station.tot_snow_24_hr_mm
    self.min_temp_24_hr_c = self.weather_station.min_temp_24_hr_c
    self.avg_temp_24_hr_c = self.weather_station.avg_temp_24_hr_c
    self.max_temp_24_hr_c = self.weather_station.max_temp_24_hr_c
    self.avg_humidity_24_hr_perc = self.weather_station.avg_humidity_24_hr_perc
    self.avg_wind_speed_24_hr_mps = self.weather_station.avg_wind_speed_24_hr_mps
    self.avg_pressure_24_hr_hPa = self.weather_station.avg_pressure_24_hr_hPa
    self.save
  end
end
