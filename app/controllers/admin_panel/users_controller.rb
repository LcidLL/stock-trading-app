class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  layout 'admin'

  def index
    @pending_traders = Trader.pending.order(created_at: :desc)
    @approved_traders = Trader.approved.order(created_at: :desc)
    @pending_transactions = Transaction.pending_approval.includes(:trader, :stock).order(created_at: :desc)
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

  def approve
    trader = Trader.find(params[:id])
    trader.update!(status: :approved)
    # TODO: Send approval email notification
    redirect_to admin_users_path, notice: "Trader #{trader.email} has been approved."
  end

  def reject
    trader = Trader.find(params[:id])
    trader.update!(status: :rejected)
    # TODO: Send rejection email notification
    redirect_to admin_users_path, notice: "Trader #{trader.email} has been rejected."
  end

  def approve_transaction
    transaction = Transaction.find(params[:transaction_id])
    transaction.approve!
    redirect_to admin_users_path, notice: "Transaction approved and executed."
  end

  def reject_transaction
    transaction = Transaction.find(params[:transaction_id])
    transaction.reject!
    redirect_to admin_users_path, notice: "Transaction rejected."
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