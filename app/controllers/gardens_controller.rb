class GardensController < ApplicationController

  #GET  /gardens/new
  def new
    @garden = Garden.new
    authorize @garden
  end

  # POST /gardens
  def create
    # make a new garden with name and address specified by user
    @garden = Garden.new(safe_params)
    authorize @garden
    # assign user to this garden
    @garden.user = current_user
    # use geocoded coordinates to locate a weather station
    @garden = geocode_address(@garden)
    binding.pry
    @garden.weather_station = WeatherStation.find_by_coords(lat, long)
    # call validation on garden
    if @garden.save
      flash[:notice] = 'Created new garden!'
      redirect_to dashboard_path
    else
      render :new
    end
  end

  private

  def safe_params
    params.require(:garden).permit(:name, :address)
  end

  def geocode_address(garden)
    results = Geocoder.search(garden.address)
    garden.latitude = results.first.coordinates[0]
    garden.longitude = results.first.coordinates[1]
    return garden
  end
end
