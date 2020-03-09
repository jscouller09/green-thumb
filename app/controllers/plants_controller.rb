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
    cur_x = @plant.x
    cur_y = @plant.y
    @plant.update(plant_params)
    if plant_space_ok?(@plant)
      render json: { accepted: true, status: 201 }
    else
      # return to original location
      errors = @plant.errors.messages
      render json: { x: cur_x, y: cur_y, accepted: false, status: 500, errors: errors }
      flash.now[:error] = errors.first
      @plant.update(x: cur_x, y: cur_y)
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:plant_type_id, :plot_id, :plant_date, :x, :y)
  end

  def plant_space_ok?(current_plant)
    # go through all plants in the current plot
    current_plant.plot.plants.each do |plant|
      unless plant == current_plant
        # check the moved plant does not overlap with another plant
        if plants_overlap?(current_plant, plant)
          # return false if it intersects any plant
          msg = "The #{current_plant.plant_type.name.downcase} you just tried to move is too close to a neighboring #{plant.plant_type.name.downcase} plant. Try nudge it to the side a bit!"
          current_plant.errors.add(:base, msg)
          return false
        end
      end
    end
    return true
  end

  def plants_overlap?(plant_1, plant_2)
    x1 = plant_1.x
    y1 = plant_1.y
    x2 = plant_2.x
    y2 = plant_2.y
    r1 = plant_1.radius_mm.fdiv(plant_1.plot.grid_cell_size_mm)
    r2 = plant_2.radius_mm.fdiv(plant_2.plot.grid_cell_size_mm)
    center_distance = Math.sqrt((x1 - x2)**2 + (y1 - y2)**2);
    radius_sum = (r1 + r2);
    if center_distance >= radius_sum
      # circles don't intersect or just touch each other
      return false
    elsif center_distance < radius_sum
      # circles intersect
      return true
    end
  end
end
