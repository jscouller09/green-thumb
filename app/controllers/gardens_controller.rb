class GardensController < ApplicationController

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
    # check the garden address gives valid coordinates (using custom validation function)
    unless @garden.valid?
      # garden address is invalid, have user try resubmit
      flash[:notice] = @garden.errors.messages[:address].first
      render :new
    else
      binding.pry
      # garden address is valid
      # use geocoded coordinates to locate a weather station
      @garden.weather_station = WeatherStation.find_by_coords(@garden.lat, @garden.lon)
      # call final validation on garden before saving
      if @garden.save
        flash[:notice] = 'Created new garden!'
        redirect_to dashboard_path
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
