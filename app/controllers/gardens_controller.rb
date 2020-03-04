class GardensController < ApplicationController

  #GET  /gardens/new
  def new
    authorize Garden
  end

  # POST /gardens
  def create
    @new_garden = Garden.new(params)
    authorize @new_garden
  end
end
