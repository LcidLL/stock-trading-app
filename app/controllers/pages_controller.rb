class PagesController < ApplicationController
  def index
    if trader_signed_in?
      redirect_to traders_dashboard_path(current_trader)
    elsif admin_user_signed_in?
      redirect_to admin_dashboard_path
    else
      redirect_to root_path
    end
  end
end