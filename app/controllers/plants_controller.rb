class PlantsController < ApplicationController

  #POST /plots/:plot_id/plants
  def create
    #set plot, plant type and date for creating a plant
    @plot = Plot.find params[:plot_id]
    # check this is the users plot before proceeding
    authorize @plot
    # first clear any surplus plants from the wheelbarrow
    # if the plant has a negative y coordinate it is in the wheelbarrow
    wheelbarrow_plants = @plot.plants.where("y IS NULL OR y < 0").destroy_all
    # create a new plant
    new_plant = Plant.new(plant_params)
    new_plant.water_deficit_mm = 0.0
    new_plant.plot_id = @plot.id
    if new_plant.save
      # making new plants succeeded
      redirect_to plot_path(@plot)
    else
      render "plots/show"
    end
  end

  # POST /plants
  def copy
    plant = Plant.find(plant_params[:id])
    # check this is the users plant
    authorize plant
    # make a new plant from supplied params and duplicating old plant
    new_plant = plant.dup
    new_plant.x = params[:x]
    new_plant.y = params[:y]
    if new_plant.save
      # making new plants succeeded
      # update count of plants in garden
      plants_counts_by_type = Hash.new(0)
      plants_icons_by_type = {}
      plant.plot.plants.where("x >= 0 AND y >= 0").each do |plant|
        type = plant.plant_type.name
        plants_counts_by_type[type] += 1
        plants_icons_by_type[type] = ActionController::Base.helpers.asset_path("icons/#{plant.plant_type.icon}")
      end
      # store new plant as JSON
      plant_obj = { id: new_plant.id,
                    x: new_plant.x,
                    y: new_plant.y,
                    planted: new_plant.planted,
                    plant_date: new_plant.plant_date,
                    radius_mm: new_plant.radius_mm,
                    plant_type: new_plant.plant_type.name.gsub(" ", "_"),
                    icon: ActionController::Base.helpers.asset_path("icons/#{new_plant.plant_type.icon}") }
      render json: { plant: plant_obj, plant_counts: plants_counts_by_type, plant_icons: plants_icons_by_type }.to_json
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

  # PATCH /plants/:id/planted
  def toggle_planted
    plant = Plant.find(params[:id])
    # check this is the users plant
    authorize plant
    plant.update(planted: !plant.planted)
    redirect_to plot_path(plant.plot)
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
    update_ok = @plant.update(plant_params)
    if update_ok && plant_space_ok?(@plant)
      render json: { accepted: true, status: 201 }
    else
      # return to original location
      unless update_ok
        msg = "Something went wrong moving that plant!"
        @plant.errors.add(:base, msg)
      end
      errors = @plant.errors.messages
      render json: { x: cur_x, y: cur_y, accepted: false, status: 500, errors: errors }
      @plant.update(x: cur_x, y: cur_y)
    end
  end

  private

  def plant_params
    params.require(:plant).permit(:id, :planted, :radius_mm, :icon, :plant_type_id, :plot_id, :plant_date, :x, :y)
  end

  def plant_space_ok?(current_plant)
    # go through all plants in the current plot
    current_plant.plot.plants.each do |plant|
      unless plant == current_plant || (plant.x.nil? && plant.y.nil?)
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
    # plant coordinates are top left corner of a square around the plant circle
    # convert to center coordinates by adding the radius to each
    r1 = plant_1.radius_mm.fdiv(plant_1.plot.grid_cell_size_mm)
    r2 = plant_2.radius_mm.fdiv(plant_2.plot.grid_cell_size_mm)
    x1 = plant_1.x + r1
    y1 = plant_1.y + r1
    x2 = plant_2.x + r2
    y2 = plant_2.y + r2
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
