class TradersController < ApplicationController
  before_action :authenticate_trader!
  before_action :ensure_approved_trader
  
  def dashboard
    @total_portfolio_value = current_trader.total_portfolio_value
    @recent_transactions = current_trader.transactions.recent.limit(5)
    @top_stocks = current_trader.portfolios.joins(:stock).limit(5)
    @pending_transactions = current_trader.transactions.pending_approval.recent.limit(5) if defined?(current_trader.transactions.pending_approval)
  end
  
  def portfolio
    @portfolios = current_trader.portfolios.includes(:stock).where('quantity > 0')
    @total_value = @portfolios.sum(&:current_value)
    @total_profit_loss = @portfolios.sum(&:profit_loss)
  end
  
  def transactions
    @transactions = current_trader.transactions.includes(:stock).recent
    @transactions = @transactions.where(transaction_type: params[:type]) if params[:type].present?
    @transactions = @transactions.where(status: params[:status]) if params[:status].present?
    # Add pagination if using kaminari: @transactions = @transactions.page(params[:page])
  end
  
  def buy_stock
    @stock = Stock.find(params[:stock_id])
    quantity = params[:quantity].to_i
    
    if quantity <= 0
      redirect_back(fallback_location: "/traders/#{current_trader.id}/dashboard", alert: 'Invalid quantity')
      return
    end
    
    # Create pending transaction instead of completed
    transaction = current_trader.transactions.build(
      stock: @stock,
      transaction_type: :buy,
      quantity: quantity,
      price: @stock.current_price,
      status: :pending
    )
    
    if transaction.save
      redirect_to "/traders/#{current_trader.id}/dashboard", 
                  notice: 'Buy order submitted! Waiting for admin approval.'
    else
      redirect_back(fallback_location: "/traders/#{current_trader.id}/dashboard", 
                   alert: 'Failed to submit buy order')
    end
  end
  
  def sell_stock
    @stock = Stock.find(params[:stock_id])
    quantity = params[:quantity].to_i
    portfolio = current_trader.portfolios.find_by(stock: @stock)
    
    if !portfolio || portfolio.quantity < quantity
      redirect_back(fallback_location: "/traders/#{current_trader.id}/portfolio", 
                   alert: 'Insufficient stocks to sell')
      return
    end
    
    # Create pending transaction
    transaction = current_trader.transactions.build(
      stock: @stock,
      transaction_type: :sell,
      quantity: quantity,
      price: @stock.current_price,
      status: :pending
    )
    
    if transaction.save
      redirect_to "/traders/#{current_trader.id}/portfolio", 
                  notice: 'Sell order submitted! Waiting for admin approval.'
    else
      redirect_back(fallback_location: "/traders/#{current_trader.id}/portfolio", 
                   alert: 'Failed to submit sell order')
    end
  end
  
  def logout
    sign_out(current_trader)
    redirect_to root_path, notice: 'Logged out successfully!'
  end
  
  private
  
  def ensure_approved_trader
    unless current_trader.approved?
      sign_out(current_trader)
      redirect_to root_path, alert: 'Your account is pending approval. Please wait for admin approval.'
    end
  end
end