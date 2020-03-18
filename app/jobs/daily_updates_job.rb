class DailyUpdatesJob < ApplicationJob
  queue_as :default

  def perform(args={})
    if args[:id]
      ActiveRecord::Base.logger.level = 1
      station = WeatherStation.find(args[:id])
      puts "Starting daily tasks for #{station.name} at #{DateTime.now}..."
      # update 24hr stats
      status_24hr_stats = station.calculate_24hr_stats
      puts "\t24hr-stats: #{status_24hr_stats}..."
      # update PET calculation
      status_24hr_pet = station.calculate_24hr_pet
      puts "\t24hr-pet: #{status_24hr_pet}..."
      # create daily summary
      summary = DailySummary.new(weather_station: station)
      status_summary = summary.save
      puts "\tsummary: #{status_summary}..."
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
      # puts status messages for plants associated with this weather station
      puts "\tplanted: #{status_planted.any?}..."
      puts "\tcrop-coeff: #{status_crop.any?}..."
      puts "\tdeficit: #{status_crop.any?}..."
      puts "\twatering: #{status_watering.any?}..."
      puts "\tdone!"

      puts "Finished daily tasks for #{station.name} at #{DateTime.now}."
      ActiveRecord::Base.logger.level = 0
    end
  end
end
