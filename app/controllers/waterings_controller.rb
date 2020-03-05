class WateringsController < ApplicationController

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
    @plot.plant_types.each do |type|


    end

    @waterings = @plot.waterings
    @plants = @plot.plants
    authorize @waterings
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
    @watering = Watering.find(params[:id])
    authorize @watering
    watering[:done] = true
  end

  private

  def watering_params
    params.require(:watering).permit(:ammount_L)
  end


end
