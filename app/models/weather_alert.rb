class WeatherAlert < ApplicationRecord
  belongs_to :weather_station
  has_many :users, through: :weather_station
  validates :message, presence: true
  validates :apply_until, presence: true
  validates :begins, presence: true
end
