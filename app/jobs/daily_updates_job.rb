class DailyUpdatesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "Starting daily tasks at #{DateTime.now}..."
    WeatherStation.all.each do |station|
      print "\tWorking on #{station.name}..."
      # update 24hr stats
      status_24hr_stats = station.calculate_24hr_stats
      print "24hr-stats:#{status_24hr_stats}..."
      # update PET calculation
      status_24hr_pet = station.calculate_24hr_pet
      print "24hr-pet:#{status_24hr_pet}..."
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
    end
    puts "Finished daily tasks at #{DateTime.now}!"
  end
end
