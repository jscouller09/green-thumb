class WateringsController < ApplicationController

  # GET /waterings  waterings#index
  def index
    authorize Watering
    @waterings = policy_scope(Watering)
  end

  # GET /waterings/:id  waterings#show
  def show
    authorize @watering
    @watering = Watering.find(params[:id])
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
