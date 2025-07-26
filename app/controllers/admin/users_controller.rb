# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  layout 'admin'

  def index
    @users = User.where(role: :trader).order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = generate_random_password unless user_params[:password].present?
    @user.password_confirmation = @user.password

    @user.role = :trader

    if @user.save
      redirect_to admin_users_path, notice: "Trader '#{@user.email}' created successfully."
    else
      flash.now[:alert] = "Failed to create trader. Please check the form for errors."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :phone_number)
  end

  def authorize_admin!
    unless current_user && current_user.admin?
      flash[:alert] = "You are not authorized to perform that action."
      redirect_to root_path
    end
  end

  def generate_random_password
    SecureRandom.hex(8)
  end
end