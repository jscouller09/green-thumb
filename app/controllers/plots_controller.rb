class PlotsController < ApplicationController

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
    @Plots = policy_scope(Plot)
  end

  # DELETE  /plots/:id
  def destroy
  end

end
