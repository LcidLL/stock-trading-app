# app/controllers/unified_sessions_controller.rb
class LoginControler < ApplicationController
  def new
   
  end

  def create
    trader = Trader.find_by(email: params[:email])

    if trader && trader.valid_password?(params[:password])
      sign_in(trader)
      redirect_to traders_dashboard_path, notice: 'Logged in as Trader successfully!'
    else
      admin_user = AdminUser.find_by(email: params[:email])

      if admin_user && admin_user.valid_password?(params[:password])
        sign_in(admin_user)
        redirect_to admin_dashboard_path, notice: 'Logged in as Admin successfully!'
      else
        # Both attempts failed
        flash.now[:alert] = 'Invalid email or password.'
        render :new, status: :unauthorized
      end
    end
  end


  include Devise::Controllers::Helpers
end