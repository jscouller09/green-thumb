class WateringsController < ApplicationController
  skip_after_action :verify_authorized, only: [:watering_plot]

  # GET /waterings
  def watering_overview
    @waterings = policy_scope(Watering)
    authorize @waterings
    @garden = policy_scope(Garden).first
    @plots = []
    @garden.plots.each do |plot|
      @plots << plot unless plot.waterings.empty?
    end

  end

  # GET plots/:plot_id/waterings
  def watering_plot
    @plot = Plot.find(params[:plot_id])
    @watering_groups = {}
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
    @plot = Plot.new
    @plot['id'] = params[:id]
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
    plot = watering.plant.plot
    authorize watering
    watering.update(done: true)
    redirect_to plot_waterings_path(plot)
  end

  private

  def watering_params
    params.require(:watering).permit(:ammount_L)
  end


end
