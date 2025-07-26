class LoginController < ApplicationController
  before_action :redirect_if_authenticated, only: [:new]
  
  def new
  end

  def create
    trader = Trader.find_by(email: params[:email])

    if trader && trader.valid_password?(params[:password])
      if trader.approved?
        sign_in(trader)
        redirect_to traders_dashboard_path(trader), notice: 'Logged in as Trader successfully!'
      else
        flash.now[:alert] = 'Your account is pending approval. Please wait for admin approval.'
        render :new, status: :unauthorized
      end
    else
      admin_user = AdminUser.find_by(email: params[:email])

      if admin_user && admin_user.valid_password?(params[:password])
        sign_in(admin_user)
        redirect_to admin_dashboard_path, notice: 'Logged in as Admin successfully!'
      else
        flash.now[:alert] = 'Invalid email or password.'
        render :new, status: :unauthorized
      end
    end
  end

  include Devise::Controllers::Helpers
  
  private
  
  def redirect_if_authenticated
    if trader_signed_in?
      redirect_to traders_dashboard_path(current_trader)
    elsif admin_user_signed_in?
      redirect_to admin_dashboard_path
    end
  end
end