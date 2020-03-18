class DailyUpdatesJob < ApplicationJob
  queue_as :default

  def perform(args={})
    if args[:id]
      ActiveRecord::Base.logger.level = 1
      station = WeatherStation.find(args[:id])
      puts "Starting daily tasks for #{station.name} at #{DateTime.now}..."

      # update 24hr stats
      status_24hr_stats = station.calculate_24hr_stats
      print "24hr-stats:#{status_24hr_stats}..."
      # update PET calculation
      status_24hr_pet = station.calculate_24hr_pet
      print "24hr-pet:#{status_24hr_pet}..."
      # create daily summary
      summary = DailySummary.new(weather_station: station)
      status_summary = summary.save
      print "summary:#{status_summary}..."
      if status_summary
        # get all measurements for the current station from last 24 hrs
        yesterday = DateTime.now.utc - 24.hours
        # assign measurements the correct daily summary
        station.measurements.where("created_at >= ?", yesterday).update_all(daily_summary_id: summary.id)
      end
      # check plants associated with this weather station
      status_planted = []
      status_crop = []
      status_deficit = []
      status_watering = []
      station.plants.each do |plant|
        # check planted
        status_planted << plant.check_planted_status
        # update crop coefficient
        status_crop << plant.update_crop_coeff
        # update water deficit
        status_deficit << plant.update_water_deficit
        # calculate watering
        status_watering << plant.generate_watering
      end
      # print status messages for plants associated with this weather station
      print "planted:#{status_planted.any?}..."
      print "crop-coeff:#{status_crop.any?}..."
      print "deficit:#{status_crop.any?}..."
      print "watering:#{status_watering.any?}..."
      puts "done!"

      puts "Finished daily tasks at #{DateTime.now}!"
      ActiveRecord::Base.logger.level = 0
    end
  end
end
