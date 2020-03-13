class WateringsController < ApplicationController
  skip_after_action :verify_authorized, only: [:watering_overview]

  # GET /waterings
  def watering_overview
    gardens = policy_scope(Garden)
    @garden = gardens.first unless gardens.empty?
    @plots = @garden.plots unless @garden.nil?
    if gardens.empty?
      # render the garden index page with an option to create a new garden
      render 'gardens/index'
    elsif @plots.nil? || @plots.empty?
      # if there are no plots go to the garden show page so you can create a plot
      render "gardens/show"
    else
      @waterings = policy_scope(Watering)
      # filter plots to be only those requiring water
      @plots = []
      @garden.plots.each do |plot|
        plot.waterings.map do |watering|
          @plots << plot unless watering.done?
        end
        @plots.uniq!
      end
      @main_plant_img = @garden.plots.map do |plot|
        unless plot.plant_types.empty?
          main_plant = plot.plant_types.group(:id).count.max.first
          PlantType.find(main_plant).photo_url
        else
          "green-thumb/logo_vztasz"
        end
      end
    end
  end

  # GET plots/:plot_id/waterings
  def watering_plot
    @plot = Plot.find(params[:plot_id])
    authorize @plot
    @plants = @plot.plants.where(planted: true)
    plants_to_json = {}
    @plants.each do |plant|
      # on plants without a position, move to wheelbarrow (negative x and y)
      plant_watering = plant.waterings.where(done: false).first
      last_watering = plant.waterings.where(done: true).order("updated_at DESC").first
      plants_to_json[plant.id] = {id: plant.id,
                                  x: plant.x.nil? ? -1 : plant.x,
                                  y: plant.y.nil? ? -1 : plant.y,
                                  planted: plant.planted,
                                  plant_date: plant.plant_date,
                                  radius_mm: plant.radius_mm,
                                  plant_type: plant.plant_type.name.gsub(" ","_"),
                                  watering: plant_watering.nil? ? 0 : plant_watering.ammount_L.round(1),
                                  watering_id: plant_watering.nil? ? nil : plant_watering.id,
                                  last_watering_date: last_watering.nil? ? nil : last_watering.updated_at.to_date,
                                  last_watering: last_watering.nil? ? nil : last_watering.ammount_L.round(1),
                                  icon: ActionController::Base.helpers.asset_path("icons/#{plant.plant_type.icon}") }
    end
    @plants_json = plants_to_json.to_json.html_safe
    @watering_groups = {}
    @plot.plant_types.each do |type|
      # get the plants of this type, in this plot
      plants = @plot.plants.where(plant_type: type)
      # pick the ones that need water (waterings that are incomplete)
      water_plants = plants.joins(:waterings).where('waterings.done' => false)
      total = 0
      water_plants.each do |plant|
        total += plant.waterings.where(done: false).sum(:ammount_L)
      end
      @watering_groups[type] = total.round(1) unless water_plants.empty?
    end
  end

  #PATCH waterings/:id
  def update
    @watering = Watering.find(params[:id])
    authorize @watering
    if @watering.update(watering_params)
      redirect_to waterings_path
    else
      render 'watering_plot'
    end
  end

  # PATCH
  def plant_type_watered
    # find a plot
    @plot = Plot.find(params[:plot_id])
    authorize @plot
    # find a specific plant_type
    @plant_type = @plot.plant_types.find(params[:plant_type_id])
    # select all the plant of that plant-type that need water
    # @waterings_plant_type = @plant_type.plants.map { |plant| plant.waterings.select { done ==false }
    @waterings_to_update = @plot.waterings.joins(:plant).where(
      done: false,
      plants: { plant_type_id: @plant_type.id }
    )
    # update all the plant of this plant type
    watering_ids = @waterings_to_update.map { |watering| watering.id }
    @waterings_to_update.update_all(done: true)
    # after watering, update the plant water deficit
    UpdateWaterDeficitJob.perform_later({waterings: watering_ids})
    redirect_to plot_waterings_path
  end

  #PATCH waterings/:id/complete
  def mark_as_complete
    watering = Watering.find(params[:id])
    authorize watering
    plot = watering.plant.plot
    watering.update(done: true)
    # after watering, update the plant water deficit
    UpdateWaterDeficitJob.perform_later({waterings: [watering.id]})
    # redirect to plot waterings
    redirect_to plot_waterings_path(plot)
  end

  # PATCH plots/:id/complete_waterings
  def complete_plot_watering
    plot = Plot.find(params[:plot_id])
    authorize plot
    waterings = plot.waterings.where(done: false)
    watering_ids = waterings.map { |watering| watering.id }
    waterings.update_all(done: true)
    # after watering, update the plant water deficit
    UpdateWaterDeficitJob.perform_later({waterings: watering_ids})
    redirect_to plot_waterings_path
  end

  private

  def watering_params
    params.require(:watering).permit(:ammount_L, :ammount_mm, :done)
  end


end
