class PlotsController < ApplicationController

  # for validations of plant positions
  # render json: { sucess: true, errors: [....]}

  # GET /plots/:id
  def show
    @plant_types = PlantType.all
    @plant = Plant.new
    @plot = Plot.find(params[:id])
    authorize @plot
    @plants = @plot.plants.where("x > 0 AND y > 0")
    plants_to_json = @plot.plants.map do |plant|
      # on plants without a position, move to wheelbarrow (negative x and y)
      { id: plant.id,
        x: plant.x.nil? ? -1 : plant.x,
        y: plant.y.nil? ? -1 : plant.y,
        planted: plant.planted,
        radius_mm: plant.radius_mm,
        icon: ActionController::Base.helpers.asset_path("icons/#{plant.plant_type.icon}"),
        photo_url: plant.plant_type.photo_url }
    end
    @plants_json = plants_to_json.to_json.html_safe
  end

  # GET /gardens/:garden_id/plots/new
  def new
    @garden = Garden.find(params[:garden_id])
    @plot = Plot.new
    authorize @plot
    authorize @garden
  end

  # POST  /gardens/:garden_id/plots/
  def create
    @garden = Garden.find(params[:garden_id])
    @plot = Plot.new(plot_params)
    authorize @plot
    authorize @garden
    # set a garden and a shape for the plot
    @plot.garden = @garden
    @plot.shape = 'rectangle'
    @plot.grid_cell_size_mm = 10
    if @plot.save
      flash[:notice] = "#{@plot.name} successfully added to your garden!"
        # go to garden show page
        redirect_to plot_path(@plot)

    else
      render :new
    end
  end

  # GET /plots/:id/edit
  def edit
    @plot = Plot.find(params[:id])
    authorize @plot
  end

  # PATCH /plots/:id/
  def update
    @plot = Plot.find(params[:id])
    authorize @plot
    if @plot.update(plot_params)
      redirect_to plot_path
    else
      render 'edit'
    end
  end

  # DELETE  /plots/:id
  def destroy
    @plot = Plot.find(params[:id])
    authorize @plot
    @garden = @plot.garden
    @plot.destroy
    flash[:notice] = "Your plot has been deleted."
    redirect_to garden_path(@garden)
  end

  private

  def plot_params
    params.require(:plot).permit(:name, :garden_id, :length_m, :width_m)
  end
end
