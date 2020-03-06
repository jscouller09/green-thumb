class PlantsController < ApplicationController

  #POST /plots/:plot_id/plants
  def create
    #set plot, plant type and date for creating a plant
    @plot = Plot.find params[:plot_id]
    # check this is the users plot before proceeding
    authorize @plot
    #create a new plant
    @plant = Plant.new(plant_params)
    # assign inital water deficit of 0 and plot id
    @plant.water_deficit_mm = 0.0
    @plant.plot = @plot
    authorize @plant
    if @plant.save
      redirect_to plot_path(@plot)
    else
      render "plots/show"
    end
  end

  # DELETE  /plants/:id
  def destroy
    @plant = Plant.find(params[:id])
    # check this is the users plant
    authorize @plant
    @plot = @plant.plot
    # check this is the users plot
    authorize @plot
    @plant.destroy
    flash[:notice] = "#{@plant.plant_type.name} has been deleted"
    redirect_to plot_path(@plot)
  end

  # PATCH /plants/:id
  def update
    # this method is only called from the JS code for shifting plants
    # should only be updating x and y of plant positions
    @plant = Plant.find(params[:id])
    # check this is the users plant
    authorize @plant
    # update the location
    if @plant.update(plant_params)
      render json: { accepted: true, status: 201 }
    else
      render json: { x: @plant.x, y: @plant.y, accepted: false, status: 500, errors: @plant.errors.messages }
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:plant_type_id, :plot_id, :plant_date, :x, :y)
  end
end
