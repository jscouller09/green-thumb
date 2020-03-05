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

    @waterings =policy_scope(Watering)
    authorize @waterings

  end

  #PATCH waterings/:id
  def update
  end

  #PATCH waterings/:id/complete
  def mark_as_complete
  end

  private

  def planet_params
    params.require(:watering).permit(:ammount_L)
  end


end
