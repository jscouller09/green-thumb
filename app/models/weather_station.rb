require 'open-uri'

class WeatherStation < ApplicationRecord
  # associations
  has_many :measurements
  has_many :gardens

  # validations
  validates :name, presence: true
  validates :country, presence: true, format: { with: /[A-Z]{2}/ }
  validates :lat,
            numericality: { greater_than_or_equal_to: -90,
                            less_than_or_equal_to: 90,
                            message: "must be in range (-90, +90)" }
  validates :lon,
            numericality: { greater_than_or_equal_to: -180,
                            less_than_or_equal_to: 180,
                            message: "must be in range (-180, +180)" }

  # constants
  OW_BASE_URL = 'http://api.openweathermap.org/data'

  WEATHER_CODES = {
    200 => { main: 'Thunderstorm', description: 'thunderstorm with light rain', icon: '11d' },
    201 => { main: 'Thunderstorm', description: 'thunderstorm with rain', icon: '11d' },
    202 => { main: 'Thunderstorm', description: 'thunderstorm with heavy rain', icon: '11d' },
    210 => { main: 'Thunderstorm', description: 'light thunderstorm', icon: '11d' },
    211 => { main: 'Thunderstorm', description: 'thunderstorm', icon: '11d' },
    212 => { main: 'Thunderstorm', description: 'heavy thunderstorm', icon: '11d' },
    221 => { main: 'Thunderstorm', description: 'ragged thunderstorm', icon: '11d' },
    230 => { main: 'Thunderstorm', description: 'thunderstorm with light drizzle', icon: '11d' },
    231 => { main: 'Thunderstorm', description: 'thunderstorm with drizzle', icon: '11d' },
    232 => { main: 'Thunderstorm', description: 'thunderstorm with heavy drizzle', icon: '11d' },

    300 => { main: 'Drizzle', description: 'light intensity drizzle', icon: '09d' },
    301 => { main: 'Drizzle', description: 'drizzle', icon: '09d' },
    302 => { main: 'Drizzle', description: 'heavy intensity drizzle', icon: '09d' },
    310 => { main: 'Drizzle', description: 'light intensity drizzle rain', icon: '09d' },
    311 => { main: 'Drizzle', description: 'drizzle rain', icon: '09d' },
    312 => { main: 'Drizzle', description: 'heavy intensity drizzle rain', icon: '09d' },
    313 => { main: 'Drizzle', description: 'shower rain and drizzle', icon: '09d' },
    314 => { main: 'Drizzle', description: 'heavy shower rain and drizzle', icon: '09d' },
    321 => { main: 'Drizzle', description: 'shower drizzle', icon: '09d' },

    500 => { main: 'Rain', description: 'light rain', icon: '10d' },
    501 => { main: 'Rain', description: 'moderate rain', icon: '10d' },
    502 => { main: 'Rain', description: 'heavy intensity rain', icon: '10d' },
    503 => { main: 'Rain', description: 'very heavy rain', icon: '10d' },
    504 => { main: 'Rain', description: 'extreme rain', icon: '10d' },
    511 => { main: 'Rain', description: 'freezing rain', icon: '13d' },
    520 => { main: 'Rain', description: 'light intensity shower rain', icon: '09d' },
    521 => { main: 'Rain', description: 'shower rain', icon: '09d' },
    522 => { main: 'Rain', description: 'heavy intensity shower rain', icon: '09d' },
    531 => { main: 'Rain', description: 'ragged shower rain', icon: '09d' },

    600 => { main: 'Snow', description: 'light snow', icon: '13d' },
    601 => { main: 'Snow', description: 'snow', icon: '13d' },
    602 => { main: 'Snow', description: 'heavy snow', icon: '13d' },
    611 => { main: 'Snow', description: 'sleet', icon: '13d' },
    612 => { main: 'Snow', description: 'light shower sleet', icon: '13d' },
    613 => { main: 'Snow', description: 'shower sleet', icon: '13d' },
    615 => { main: 'Snow', description: 'light rain and snow', icon: '13d' },
    616 => { main: 'Snow', description: 'rain and snow', icon: '13d' },
    620 => { main: 'Snow', description: 'light shower snow', icon: '13d' },
    621 => { main: 'Snow', description: 'shower snow', icon: '13d' },
    622 => { main: 'Snow', description: 'heavy shower snow', icon: '13d' },

    701 => { main: 'Mist', description: 'mist', icon: '50d' },
    711 => { main: 'Smoke', description: 'smoke', icon: '50d' },
    721 => { main: 'Haze', description: 'haze', icon: '50d' },
    731 => { main: 'Dust', description: 'sand/dust whirls', icon: '50d' },
    741 => { main: 'Fog', description: 'fog', icon: '50d' },
    751 => { main: 'Sand', description: 'sand', icon: '50d' },
    761 => { main: 'Dust', description: 'dust', icon: '50d' },
    762 => { main: 'Ash', description: 'volcanic ash', icon: '50d' },
    771 => { main: 'Squall', description: 'squalls', icon: '50d' },
    781 => { main: 'Tornado', description: 'tornado', icon: '50d' },

    800 => { main: 'Clear', description: 'clear sky', icon: ['01d', '01n'] },
    801 => { main: 'Clouds', description: 'few clouds (11-25%)', icon: ['02d', '02n'] },
    802 => { main: 'Clouds', description: 'scattered clouds (25-50%)', icon: ['03d', '03n'] },
    803 => { main: 'Clouds', description: 'broken clouds (50-85%)', icon: ['04d', '04n'] },
    804 => { main: 'Clouds', description: 'overcast clouds (85-100%)', icon: ['04d', '04n'] },
  }

  def download_current_weather
    # build url
    url = "#{OW_BASE_URL}/2.5/weather?"
    url += "id=#{id}&appid=#{ENV['OW_API_KEY']}&units=metric"
    # send query and format data
    format_response(send_query(url))
  end

  def download_3hrly_5d_forecast
    # build url
    url = "#{OW_BASE_URL}/2.5/forecast?"
    url += "id=#{id}&appid=#{ENV['OW_API_KEY']}&units=metric"
    # send query
    data = send_query(url)
    # format responses
    forecast = data[:list].map do |timestep|
      timestep[:timezone] = data[:city][:timezone]
      format_response(timestep)
    end
    forecast
  end

  def self.find_by_coords(lat, lon)
    # build url
    url = "#{OW_BASE_URL}/2.5/weather?lat=#{lat}&lon=#{lon}"
    url += "&appid=#{ENV['OW_API_KEY']}&units=metric"
    # send query
    # query API and return JSON
    serialised_data = URI.open(url).read
    data = JSON.parse(serialised_data, symbolize_names: true)
    # check if this station exists in the DB or not
    begin
      WeatherStation.find(data[:id])
    rescue ActiveRecord::RecordNotFound
      # build weather station instance, save to DB and return it
      return WeatherStation.create(id: data[:id],
                                   name: data[:name],
                                   country: data[:sys][:country],
                                   lat: data[:coord][:lat],
                                   lon: data[:coord][:lon])
    else
      # weather station exists, use it
      return WeatherStation.find(data[:id])
    end
  end

  private

  def send_query(url)
    # query API and return JSON
    serialised_data = URI.open(url).read
    JSON.parse(serialised_data, symbolize_names: true)
  end

  def format_response(data = {})
    data_to_keep = {}
    tz = data[:timezone]
    unless data[:sys][:sunrise].nil?
      data_to_keep[:sunrise] = DateTime.strptime((data[:sys][:sunrise] + tz).to_s,'%s')
      data_to_keep[:sunset] = DateTime.strptime((data[:sys][:sunset] + tz).to_s,'%s')
    end
    data_to_keep[:timestamp] = DateTime.strptime((data[:dt] + tz).to_s,'%s')
    data_to_keep[:timezone_UTC_offset] = DateTime.strptime(tz.to_s,'%s').strftime("#{tz.negative? ? '-' : '+'}%H%M")
    data_to_keep[:temp_c] = data[:main][:temp]
    data_to_keep[:humidity_perc] = data[:main][:humidity]
    data_to_keep[:pressure_hPa] = data[:main][:pressure]
    data_to_keep[:wind_speed_mps] = data[:wind][:speed]
    data_to_keep[:wind_direction_deg] = data[:wind][:deg]
    data_to_keep[:cloudiness_perc] = data[:clouds][:all]
    data_to_keep[:code] = data[:weather].first[:id]
    data_to_keep[:main] = data[:weather].first[:main]
    data_to_keep[:description] = data[:weather].first[:description]
    data_to_keep[:icon] = data[:weather].first[:icon]
    unless data[:rain].nil?
      data_to_keep[:rain_1h_mm] = data[:rain][:"1h"]
      data_to_keep[:rain_3h_mm] = data[:rain][:"3h"]
    else
      data_to_keep[:rain_1h_mm] = 0.0
      data_to_keep[:rain_3h_mm] = 0.0
    end
    unless data[:snow].nil?
      data_to_keep[:snow_1h_mm] =  data[:snow][:"1h"]
      data_to_keep[:snow_3h_mm] = data[:snow][:"3h"]
    else
      data_to_keep[:snow_1h_mm] = 0.0
      data_to_keep[:snow_3h_mm] = 0.0
    end
    data_to_keep
  end
end
