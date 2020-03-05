class PlantsController < ApplicationController

  #POST /plots/:plot_id/plants
  def create
    #set plot, plant type and date for creating a plant
    @plot = Plot.find params[:plot_id]
    @plant_type = PlantType.find params['plant']['plant_type_id']
    @plant_date = @plant_type.earliest_plant_day

    #create a new plant
    @plant = Plant.new(
      plant_type_id: plant_params['plant_type_id'],
      plot_id: params[:plot_id],
      plant_date: @plant_date,
      water_deficit_mm: 0
    )
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
    @plot = @plant.plot
    authorize @plant

    @plant.destroy
    flash[:notice] = "#{@plant.plant_type.name} has been deleted"
    redirect_to plot_path(@plot)
  end

  private

  def plant_params
    params.require(:plant).permit(:plant_type_id, :plot_id, :plant_date)
  end
end
