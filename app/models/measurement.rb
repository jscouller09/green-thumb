class Measurement < ApplicationRecord
  # associations
  belongs_to :weather_station
  belongs_to :daily_summary, optional: true

  # validations
  validates_associated :weather_station

  # must have timestamp and timezone offset from UTC
  validates :timestamp, presence: true
  validates :timezone_UTC_offset, presence: true, format: { with: /-?\d{2}:\d{2}/ }

  # check these measurements are present as they are necessary for PET calcs
  validates :temp_c, numericality: true
  # assume RH cant exceed 110% (some margin for super saturated air)
  validates :humidity_perc,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 110,
                            message: "must be integer in range (0, +110)" }
  validates :wind_speed_mps, numericality: { greater_than_or_equal_to: 0 }

  # check zero has been added for these measurements
  # they are only reported by OpenWeather when they occur
  validates :rain_1h_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :rain_3h_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :snow_1h_mm, numericality: { greater_than_or_equal_to: 0 }
  validates :snow_3h_mm, numericality: { greater_than_or_equal_to: 0 }

  def timestamp_UTC
    tz = self.timezone_UTC_offset
    self.timestamp.change(offset: tz[0] == "-" ? tz : "+#{tz}")
  end
end
