require 'open-uri'

class WeatherStation < ApplicationRecord
  # associations
  has_many :measurements, dependent: :destroy
  has_many :weather_alerts, dependent: :destroy
  has_many :daily_summaries, dependent: :destroy
  has_many :gardens, dependent: :destroy
  has_many :users, through: :gardens
  has_many :plots, through: :gardens
  has_many :plants, through: :plots
  has_many :waterings, through: :plants

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

  after_create :download_elevation

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


  def check_forecast_for_alerts
    # get forecast data
    forecast = download_3hrly_5d_forecast
    # get current alerts and the codes associated with them
    alert_ids = self.weather_alerts.where("apply_until >= ?", DateTime.now()).select(:id).map { |a| a.id }
    alert_codes = alert_ids.map { |a| WeatherAlert.find(a).code }
    # go through each predicition in the forecast over the next 3 days = 72 hrs = 24x3hr intervals
    forecast.first(24).each do |prediction|
      # convert timestamp to UTC
      tz = prediction[:timezone_UTC_offset]
      timestamp_UTC = prediction[:timestamp].change(offset: tz[0] == "-" ? tz : "+#{tz}")
      # check weather code and group together if necessary
      code = prediction[:code]
      #code = 212
      if [202, 211, 212, 221].include?(code)
        # intense thunderstorms
        grouped_code = 2000
      elsif [502, 503, 504].include?(code)
        # heavy rainfall codes
        grouped_code = 5000
      elsif code >= 600 && code <= 622
        # snow/sleet codes
        grouped_code = 6000
      else
        grouped_code = code
      end
      # check if we need to generate a severe weather alert
      if !alert_codes.include?(grouped_code)
        new_alert = generate_weather_alert(grouped_code, prediction, timestamp_UTC)
        # add alert to list of alerts
        if new_alert && new_alert.save
          alert_ids << new_alert.id
          alert_codes << new_alert.code
        end
      else
        # this code exists, update the applies until to the current timestamp
        # find most recent alert for this code
        alert_id = alert_ids[alert_codes.rindex(grouped_code)]
        alert = WeatherAlert.find(alert_id)
        # update the apply_until timestamp
        alert.update(apply_until: timestamp_UTC)
        # update the begin timestamp
        alert.update(begins: [DateTime.now, alert.begins].max)
      end
      # check if we need to generate a frost alert
      if prediction[:temp_c] <= 1.0
        # possibility of frost => code = 0000
        if !alert_codes.include?(0000)
        new_alert = generate_weather_alert(0000, prediction, timestamp_UTC)
        # add alert to list of alerts
        if new_alert && new_alert.save
          alert_ids << new_alert.id
          alert_codes << new_alert.code
        end
        else
          # already have a frost predicted, update the applies until to the current timestamp
          # find most recent alert for this code
          alert_id = alert_ids[alert_codes.rindex(0000)]
          alert = WeatherAlert.find(alert_id)
          # update the apply_until timestamp
          alert.update(apply_until: timestamp_UTC)
          # update the begin timestamp
          alert.update(begins: [DateTime.now, alert.begins].max)
        end
      end
    end
    # return true if there are some alerts in effect, false otherwise
    return !alert_ids.empty?
  end

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
    measurements = self.measurements.where("created_at >= ?", yesterday).order(created_at: :asc)
    # convert timestamp to UTC
    last_measurement = measurements.last
    tz = last_measurement[:timezone_UTC_offset]
    timestamp_UTC = last_measurement[:timestamp].change(offset: tz[0] == "-" ? tz : "+#{tz}")
    self.timestamp = timestamp_UTC
    # min and max temperature are straightforward
    self.min_temp_24_hr_c = measurements.minimum(:temp_c)
    self.max_temp_24_hr_c = measurements.maximum(:temp_c)
    # for totals/averages need to consider timing of measurements
    cur_ts = measurements.first.timestamp
    last_ts = measurements.first.timestamp
    total_ts = 0
    total_rain = 0.0
    total_snow = 0.0
    avg_t = 0.0
    avg_h = 0.0
    avg_w = 0.0
    avg_p = 0.0
    measurements.each do |meas|
      # for total rainfall and snowfall, only add if 1 hr apart to avoid double ups
      if meas.timestamp >= cur_ts + 58.minutes
        # measurements are approx 1 hour apart, add total rainfall and snow
        total_rain += meas.rain_1h_mm
        total_snow += meas.snow_1h_mm
        # update last timestamp
        cur_ts = meas.timestamp
      end
      # for average measurements, weight by duration between measurements
      delta_t_ms = meas.timestamp - last_ts
      total_ts += delta_t_ms
      avg_t += delta_t_ms * meas.temp_c
      avg_h += delta_t_ms * meas.humidity_perc
      avg_w += delta_t_ms * meas.wind_speed_mps
      avg_p += delta_t_ms * meas.pressure_hPa
      last_ts = meas.timestamp
    end
    self.tot_rain_24_hr_mm = total_rain
    self.tot_snow_24_hr_mm = total_snow
    self.avg_temp_24_hr_c = avg_t / total_ts
    self.avg_humidity_24_hr_perc = avg_h / total_ts
    self.avg_wind_speed_24_hr_mps = avg_w / total_ts
    self.avg_pressure_24_hr_hPa = avg_p / total_ts
    self.save
  end

  def calculate_24hr_pet
    # TEMP
    t_max = self.max_temp_24_hr_c
    t_min = self.min_temp_24_hr_c
    t = (t_max + t_min) / 2.0

    # VAPOR PRESSURE DEFICIT
    vapour_p = lambda { |x| 0.6108 * Math.exp(17.27 * x / (x + 237.3)) }
    e_t_min = vapour_p.call(t_min)
    e_t_max = vapour_p.call(t_max)
    e_s = (e_t_min + e_t_max) / 2.0
    e_a = e_s * (self.avg_humidity_24_hr_perc / 100.0)
    vpd = e_s - e_a

    # WIND
    # calculate 2m high windspeed assuming measured at 2m from surface
    adj_windspeed = lambda { |u, y| u * (4.87 / Math.log(67.8*y - 5.42)) }
    # u_2 = adj_windspeed.call(self.avg_wind_speed_24_hr_mps, 10.0)
    u_2 = adj_windspeed.call(self.avg_wind_speed_24_hr_mps, 2.0)

    # NET RADIATION
    # julian day
    j = ((275 * (self.timestamp.month / 9.0) - 30 + self.timestamp.day) - 2).to_i
    # inverse relative distance earth-sun
    d_r = 1 + (0.333 * Math.cos(2.0 * Math::PI * j / 365))
    # latitude (radians)
    phi = Math::PI * self.lat / 180.0
    # solar declination (radians)
    delta = 0.409 * Math::sin((2.0 * Math::PI * j / 365) - 1.39)
    # sunset hour angle (radians)
    omega_s = Math.acos(-Math.tan(phi)*Math.tan(delta))
    # extr terrestrial radiation
    r_a = (24*60 / Math::PI) * 0.082 * d_r * (omega_s*Math.sin(phi)*Math.sin(delta) + Math.cos(phi)*Math.cos(delta)*Math.sin(omega_s))
    # solar radiation
    # assume interior locations Krs = 0.16 for now (0.19 for coastal)
    r_s = 0.16 * Math.sqrt(t_max - t_min) * r_a
    # clear sky solar radiation
    r_s0 = (0.75 + 2.0e-5 * self.elevation_m) * r_a
    # net solar radiation
    r_ns = (1 - 0.23) * r_s
    # net long wave radiation
    r_nl = 4.903e-9*((t_max + 237.16)**4 + (t_min + 237.16)**4) * (0.34 - 0.14*Math.sqrt(e_a)) * ((1.35*r_s/r_s0) - 0.35)/ 2.0
    # net radiation
    r_n = r_ns - r_nl

    # SLOPE OF VAPOUR PRESSURE CURVE
    delta_caps = 4098 * vapour_p.call(t) / ((t + 237.13)**2)

    # PSYCHOMETRIC CONSTANT
    # assume can be calculated based off average pressure instead of elevation
    gamma = 0.665e-3 * self.avg_pressure_24_hr_hPa / 10.0

    # REFERENCE PET
    # note for daily calcs assume G = soil heat flux density = 0
    et_0_numerator = 0.408*delta_caps*r_n + gamma*900.0*u_2*vpd/(t+273.0)
    et_0_denomenator = delta_caps + gamma*(1.0 + 0.34*u_2)
    et_0 = et_0_numerator / et_0_denomenator

    self.tot_pet_24_hr_mm = et_0
    status1 = self.save

    # also create an instance of daily_summary
    summary = DailySummary.new(weather_station: self)
    status2 = summary.save
    if status2
      # get all measurements for the current station from last 24 hrs
      yesterday = DateTime.now.utc - 24.hours
      # assign measurements the correct daily summary
      self.measurements.where("created_at >= ?", yesterday).update_all(daily_summary_id: summary.id)
    end

    # return status of saves
    status1 && status2
  end

  def weather_summary
    # get current data
    summary = {}
    summary[:now] = download_current_weather
    # store current weather as a measurement instance
    meas = Measurement.new(summary[:now])
    meas.weather_station =  self
    meas.save
    # update stats for last 24hrs
    calculate_24hr_stats
    calculate_24hr_pet
    # get stats for last 24hrs
    summary[:now][:timestamp] = timestamp
    summary[:now][:tot_rain_24_hr_mm] = tot_rain_24_hr_mm
    summary[:now][:tot_pet_24_hr_mm] = tot_pet_24_hr_mm
    summary[:now][:tot_snow_24_hr_mm] = tot_snow_24_hr_mm
    summary[:now][:min_temp_24_hr_c] = min_temp_24_hr_c
    summary[:now][:avg_temp_24_hr_c] = avg_temp_24_hr_c
    summary[:now][:max_temp_24_hr_c] = max_temp_24_hr_c
    summary[:now][:avg_humidity_24_hr_perc] = avg_humidity_24_hr_perc
    summary[:now][:avg_wind_speed_24_hr_mps] = avg_wind_speed_24_hr_mps
    summary[:now][:avg_pressure_24_hr_hPa] = avg_pressure_24_hr_hPa
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
      stn = self.find(data[:id])
    rescue ActiveRecord::RecordNotFound => e
      puts e.message
      puts "Station not in DB, making new one...."
      # build weather station instance, save to DB and return it
      stn = self.new(id: data[:id],
                     name: data[:name],
                     country: data[:sys][:country],
                     lat: data[:coord][:lat],
                     lon: data[:coord][:lon])
      stn.save
      return stn
    end
    return stn
  end

  private

  def generate_weather_alert(code, prediction, timestamp_UTC)
    if code == 0000
      # frost custom code
      msg = "potential frosts"
    elsif code == 2000
      # intense thunderstorms
      msg = "thunderstorms"
    elsif code == 5000
      # heavy rainfall
      msg = "heavy rainfall"
    elsif code == 6000
      # snow/sleet
      msg = "snow or sleet"
    elsif code == 511
      # freezing rain
      msg = "freezing rain"
    elsif code == 771
      # squall
      msg = "squalls"
    elsif code == 781
      # tornado
      msg = "tornado"
    else
      # not a weather code that needs an alert
      return nil
    end
    # generate alert with the correct message
    new_alert = WeatherAlert.new(code: code,
                                 main: prediction[:main],
                                 description: prediction[:description],
                                 weather_station_id: self.id,
                                 begins: timestamp_UTC,
                                 apply_until: timestamp_UTC,
                                 message: msg)
  end

  def download_elevation
    # download elevation of coordinates from open topo
    # https://www.opentopodata.org/
    elevation_url = "#{OPEN_TOPO_URL}#{self.lat},#{self.lon}"
    serialised_data = URI.open(elevation_url).read
    elev_data = JSON.parse(serialised_data, symbolize_names: true)
    self.elevation_m = elev_data[:results].first[:elevation]
    self.save
  end

  def wind_direction(deg)
    # convert wind direction in degrees to cardinal direction
    unless deg.nil?
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
    return ''
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
    data_to_keep[:timezone_UTC_offset] = DateTime.strptime(tz.to_s,'%s').strftime("#{tz.negative? ? '-' : ''}%H:%M")
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
      data_to_keep[:rain_1h_mm] = data[:rain][:"1h"].nil? ? 0.0 : data[:rain][:"1h"]
      data_to_keep[:rain_3h_mm] = data[:rain][:"3h"].nil? ? 0.0 : data[:rain][:"3h"]
    else
      data_to_keep[:rain_1h_mm] = 0.0
      data_to_keep[:rain_3h_mm] = 0.0
    end
    unless data[:snow].nil?
      data_to_keep[:snow_1h_mm] =  data[:snow][:"1h"].nil? ? 0.0 : data[:snow][:"1h"]
      data_to_keep[:snow_3h_mm] = data[:snow][:"3h"].nil? ? 0.0 : data[:snow][:"3h"]
    else
      data_to_keep[:snow_1h_mm] = 0.0
      data_to_keep[:snow_3h_mm] = 0.0
    end
    data_to_keep
  end
end
