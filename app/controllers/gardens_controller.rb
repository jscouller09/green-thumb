class GardensController < ApplicationController

  #GET  /gardens
  def index
    @gardens = policy_scope(Garden)
    if @gardens.empty?
      # render the index page with an option to create a new garden
      render :index
    else
      # go to show page of first garden
      # may add more gardens later but for now 1 garden per user
      redirect_to garden_path(@gardens.first)
    end
  end

  #GET  /gardens/:id
  def show
    @garden = Garden.find(params[:id])
    authorize @garden
    @plots = @garden.plots
    # Display image for the plant that the plot has the most of
    @main_plant_img = @plots.map do |plot|
      unless plot.plant_types.empty?
        # find the id of the most common plant in your garden
        main_plant = plot.plant_types.group(:id).count.max_by {|k, v| v}.first
        PlantType.find(main_plant).photo_url
      else
        "green-thumb/logo_vztasz"
      end
    end
  end

  #GET  /gardens/new
  def new
    @garden = Garden.new
    authorize @garden
  end

  # POST /gardens
  def create
    # make a new garden with name and address specified by current_user
    @garden = Garden.new(safe_params)
    authorize @garden
    @garden.user = current_user
    # check the garden address gives valid coordinates
    # this is done using custom validation function which attempts to geocode it
    @garden.valid?
    unless @garden.errors.details[:address].empty? && @garden.errors.messages[:address].empty?
      # garden address is invalid, have user try resubmit a new address
      flash[:notice] = @garden.errors.messages[:address].first
      render :new
    else
      # garden address is valid and has been geocoded
      # use geocoded coordinates to locate a weather station
      @garden.weather_station = WeatherStation.find_by_coords(@garden.lat, @garden.lon)
      # call final validation on garden before saving
      if @garden.save
        flash[:notice] = 'Created new garden!'
        # download current weather and store measurement
        data = @garden.weather_station.download_current_weather
        meas = Measurement.new(data)
        meas.weather_station = @garden.weather_station
        meas.save!
        # go to garden show page
        redirect_to garden_path(@garden)
      else
        render :new
      end
    end
  end

  private

  def safe_params
    params.require(:garden).permit(:name, :address)
  end
end
