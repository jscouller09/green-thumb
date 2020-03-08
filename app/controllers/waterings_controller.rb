class WateringsController < ApplicationController
  skip_after_action :verify_authorized, only: [:complete_plot_watering, :watering_overview]

  # GET /waterings
  def watering_overview
    @waterings = policy_scope(Watering)
    @garden = policy_scope(Garden).first
    @plots = []
    @garden.plots.each do |plot|
      plot.waterings.map do |watering|
        @plots << plot unless watering.done?
      end
      @plots.uniq!
    end
  end

  # GET plots/:plot_id/waterings
  def watering_plot
    @plot = Plot.find(params[:plot_id])
    authorize @plot
    @plant = Plant.new
    @watering_groups = {}
    @plants = @plot.plants
    plants_to_json = @plants.map do |plant|
      { id: plant.id,
        x: plant.x,
        y: plant.y,
        radius_mm: plant.radius_mm,
        photo_url: plant.plant_type.photo_url }
    end
    @plants_json = plants_to_json.to_json.html_safe
    @plot.plant_types.each do |type|
      # get the plants of this type, in this plot
      plants = @plot.plants.where(plant_type: type)
      # pick the ones that need water (waterings that are incomplete)
      water_plants = plants.joins(:waterings).where('waterings.done' => false)
      @watering_groups[type] = water_plants unless water_plants.empty?
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

  #PATCH waterings/:id/complete
  def mark_as_complete
    watering = Watering.find(params[:id])
    authorize watering
    plot = watering.plant.plot
    watering.update(done: true)
    redirect_to plot_waterings_path(plot)
  end

  # PATCH plots/:id/complete_waterings
  def complete_plot_watering
    plot = Plot.find(params[:plot_id])
    waterings = plot.waterings
    waterings.each do |watering|
      watering.update(done: true)
    end
      redirect_to plot_waterings_path
  end

  private

  def watering_params
    params.require(:watering).permit(:ammount_L, :ammount_mm, :done)
  end


end
