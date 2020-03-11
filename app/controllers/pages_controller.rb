class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  skip_after_action :verify_authorized, only: [:dashboard, :home]

  def home
    # redirect_to "https://jscouller09.github.io/green-thumb-landing-page/"
  end

  #GET  /dashboard
  def dashboard
  end
end
