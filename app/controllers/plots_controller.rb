class PlotsController < ApplicationController

  # GET /plots/:id
  def show
    @plot = Plot.find(params[:id])
    authorize @plot
  end

  # GET /gardens/:garden_id/plots/new
  def new
  end

  # POST  /gardens/:garden_id/plots/
  def create
  end

  # GET /plots/:id/edit
  def edit
  end

  # PATCH /plots/:id/
  def update
  end

  # DELETE  /plots/:id
  def destroy
  end

  # PATCH plots/:id/complete_waterings
  def complete_watering
  end

  private

  def plot_params
    params.require(:plot).permit(:name, :garden)
  end
end
