class UpdateWaterDeficitJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    # update the water deficits for the plants associated with the supplied waterings
    waterings_ids = args[:waterings]
    puts "Updating waterings in the background..."
    if waterings_ids
      waterings_ids.each do |id|
        watering = Watering.find(id)
        status = watering.update_plant_water_deficit
        puts "\tWatering #{id} deficit updated... #{status}"
      end
    end
    puts "Done!"
  end
end
