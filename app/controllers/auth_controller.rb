class AuthController < ApplicationController
  before_action :redirect_if_authenticated, except: [:trader_authenticate, :admin_authenticate, :create_trader_account]

  def index; end

  def trader_login; end

  def admin_login; end

  def trader_signup
    @trader = Trader.new
  end

  def create_trader_account
    @trader = Trader.new(trader_params)
    
    if Rails.env.development?
      @trader.status = :approved
      notice_message = 'Account created and auto-approved for development! You can now login.'
    else
      @trader.status = :pending
      notice_message = 'Account created successfully! Please wait for admin approval before logging in.'
    end

    if @trader.save
      redirect_to root_path, notice: notice_message
    else
      flash.now[:alert] = 'Failed to create account. Please check the form for errors.'
      render :trader_signup, status: :unprocessable_entity
    end
  end

  def trader_authenticate
    trader = Trader.find_by(email: params[:email])
    
    # DEBUG
    Rails.logger.info "=== TRADER LOGIN DEBUG ==="
    Rails.logger.info "Email received: #{params[:email]}"
    Rails.logger.info "Password received: #{params[:password].present? ? '[PRESENT]' : '[MISSING]'}"
    Rails.logger.info "Trader found: #{trader.present?}"
    Rails.logger.info "Trader status: #{trader&.status}"
    Rails.logger.info "Password valid: #{trader&.valid_password?(params[:password])}" if trader

    if trader && trader.valid_password?(params[:password])
      if trader.approved?
        sign_in(trader)
        redirect_to "/traders/#{trader.id}/dashboard", notice: 'Logged in as Trader successfully!'
      else
        flash.now[:alert] = 'Your account is pending approval. Please wait for admin approval.'
        render :trader_login, status: :unauthorized
      end
    else
      flash.now[:alert] = 'Invalid email or password.'
      render :trader_login, status: :unauthorized
    end
  end

  def admin_authenticate
    admin_user = AdminUser.find_by(email: params[:email])

    if admin_user && admin_user.valid_password?(params[:password])
      sign_in(admin_user)
      redirect_to admin_dashboard_path, notice: 'Logged in as Admin successfully!'
    else
      flash.now[:alert] = 'Invalid email or password.'
      render :admin_login, status: :unauthorized
    end
  end

  private

  def redirect_if_authenticated
    if trader_signed_in?
      redirect_to "/traders/#{current_trader.id}/dashboard"
    elsif admin_user_signed_in?
      redirect_to admin_dashboard_path
    end
  end

  def trader_params
    params.require(:trader).permit(:email, :password, :password_confirmation)
  end
end