class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    redirect_to "https://jscouller09.github.io/green-thumb-landing-page/"
  end

  #GET  /dashboard
  def dashboard

  end
end
