class WateringsController < ApplicationController

  # GET /waterings
  def watering_overview
    @waterings = policy_scope(Watering)
    authorize @waterings
    @watering = Watering.new
    @garden = policy_scope(Garden).first
    @plots = []
    @garden.plots.each do |plot|
      @plots << plot unless plot.waterings.empty?
    end

  end

  # GET plots/:plot_id/waterings
  def watering_plot
    @waterings = policy_scope(Watering)
    authorize @waterings
    @plot = Plot.new
    @plot['id'] = params[:id]
    @user = current_user
    @plants = @user.gardens.first.plants
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
    authorize @watering
    watering[:done] = true
  end

  private

  def planet_params
    params.require(:watering).permit(:ammount_L)
  end


end
