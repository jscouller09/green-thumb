require 'open-uri'

class WeatherStation < ApplicationRecord
  # associations
  has_many :measurements
  has_many :gardens
  has_many :users, through: :gardens

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
  validates :elevation_m,
            numericality: { allow_nil: true }
  validates :tot_rain_24hr_mm,
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

  # constants
  OW_BASE_URL = 'http://api.openweathermap.org/data'
  OPEN_TOPO_URL = 'https://api.opentopodata.org/v1/aster30m?locations='

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

    800 => { main: 'Clear', description: 'clear sky', icon: '01d', icon_night: '01n' },
    801 => { main: 'Clouds', description: 'few clouds', icon: '02d', icon_night: '02n' }, # (11-25%)
    802 => { main: 'Clouds', description: 'scattered clouds', icon: '03d', icon_night: '03n' }, # (25-50%)
    803 => { main: 'Clouds', description: 'broken clouds', icon: '04d', icon_night: '04n' }, # (50-85%)
    804 => { main: 'Clouds', description: 'overcast clouds', icon: '04d', icon_night: '04n' }, # (85-100%)
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

  def calculate_24hr_stats
    # get all measurements for the current station from last 24 hrs
    yesterday = DateTime.now.utc - 24.hours
    self.tot_rain_24hr_mm = self.measurements.where("created_at >= ?", yesterday).sum(:rain_1h_mm)
    self.min_temp_24_hr_c = self.measurements.where("created_at >= ?", yesterday).minimum(:temp_c)
    self.avg_temp_24_hr_c = self.measurements.where("created_at >= ?", yesterday).average(:temp_c)
    self.max_temp_24_hr_c = self.measurements.where("created_at >= ?", yesterday).maximum(:temp_c)
    self.avg_humidity_24_hr_perc = self.measurements.where("created_at >= ?", yesterday).average(:humidity_perc)
    self.avg_wind_speed_24_hr_mps = self.measurements.where("created_at >= ?", yesterday).average(:wind_speed_mps)
    self.avg_pressure_24_hr_hPa = self.measurements.where("created_at >= ?", yesterday).average(:pressure_hPa)
  end

  def calculate_24hr_pet
    # add calcs for PET measurements
  end

  def weather_summary
    # get current data
    summary = {}
    summary[:now] = download_current_weather
    # get forecast data
    forecast = download_3hrly_5d_forecast
    # seperate data into measurements for different days
    summary[:today] = summary[:now][:timestamp].to_date
    data = {}
    forecast.each do |prediction|
        # get the full name of the day
        day = prediction[:timestamp].to_date.strftime('%A')
        data[day] = {} if data[day].nil?
        # for each of the measurement in the prediction, append to array
        prediction.each do |key, val|
          data[day][key] = data[day][key].nil? ? [val] : data[day][key] << val
        end
    end
    # generate daily summary of forecast
    data.each do |day, vals|
      summary[day] = {}
      num_meas = vals[:timestamp].count
      # do min, max and avg temp
      summary[day][:temp_c_avg] = vals[:temp_c].sum.fdiv(num_meas)
      summary[day][:temp_c_min] = vals[:temp_c].min
      summary[day][:temp_c_max] = vals[:temp_c].max
      # do total rainfall
      summary[day][:rain_mm_tot] = vals[:rain_3h_mm].sum
      # do total snowfall only if there is any snow
      snow = vals[:snow_3h_mm].sum
      summary[day][:snow_mm_tot] = snow if snow > 0
      # do average humidity
      summary[day][:humidity_perc_avg] = vals[:humidity_perc].sum.fdiv(num_meas)
      # do average wind speed and direction
      summary[day][:wind_speed_mps_avg] = vals[:wind_speed_mps].sum.fdiv(num_meas)
      summary[day][:wind_direction_deg_avg] = vals[:wind_direction_deg].sum.fdiv(num_meas)
      summary[day][:wind_direction] = wind_direction(summary[day][:wind_direction_deg_avg])
      # do most frequently occurring weather code to get description/icon
      summary[day][:code] = vals[:code].max_by { |i| vals[:code].count(i) }
      summary[day][:main] = WEATHER_CODES[summary[day][:code]][:main]
      summary[day][:description] = WEATHER_CODES[summary[day][:code]][:description]
      summary[day][:icon] = WEATHER_CODES[summary[day][:code]][:icon]
    end
    summary
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
      # download elevation data for the station coords from open topo
      z = download_elevation(data[:coord][:lat], data[:coord][:lon])
      # build weather station instance, save to DB and return it
      return WeatherStation.create(id: data[:id],
                                   name: data[:name],
                                   country: data[:sys][:country],
                                   lat: data[:coord][:lat],
                                   lon: data[:coord][:lon],
                                   elevation_m: z)
    else
      # weather station exists, use it
      return WeatherStation.find(data[:id])
    end
  end

  private

  def self.download_elevation(lat, lon)
    # download elevation of coordinates from open topo
    # https://www.opentopodata.org/
    elevation_url = "#{OPEN_TOPO_URL}#{lat},#{lon}"
    serialised_data = URI.open(elevation_url).read
    elev_data = JSON.parse(serialised_data, symbolize_names: true)
    elev_data[:results].first[:elevation]
  end

  def wind_direction(deg)
    # convert wind direction in degrees to cardinal direction
    return 'N' if deg <= 11.25 || deg > 348.75
    return 'NNE' if deg > 11.25 && deg <= 33.75
    return 'NE' if deg > 33.75 && deg <= 56.25
    return 'ENE' if deg > 56.25 && deg <= 78.75
    return 'E' if deg > 78.75 && deg <= 101.25
    return 'ESE' if deg > 101.25 && deg <= 123.75
    return 'SE' if deg > 123.75 && deg <= 146.25
    return 'SSE' if deg > 146.25 && deg <= 168.75
    return 'S' if deg > 168.75 && deg <= 191.25
    return 'SSW' if deg > 191.25 && deg <= 213.75
    return 'SW' if deg > 213.75 && deg <= 236.25
    return 'WSW' if deg > 236.25 && deg <= 258.75
    return 'W' if deg > 258.75 && deg <= 281.25
    return 'WNW' if deg > 281.25 && deg <= 303.75
    return 'NW' if deg > 303.75 && deg <= 326.25
    return 'NNW' if deg > 326.25 && deg <= 348.75
  end

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
    data_to_keep[:temp_feels_like_c] = data[:main][:feels_like]
    data_to_keep[:humidity_perc] = data[:main][:humidity]
    data_to_keep[:pressure_hPa] = data[:main][:pressure]
    data_to_keep[:wind_speed_mps] = data[:wind][:speed]
    data_to_keep[:wind_direction_deg] = data[:wind][:deg]
    data_to_keep[:wind_direction] = wind_direction(data[:wind][:deg])
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
