class TradersController < ApplicationController
  before_action :authenticate_trader!
  before_action :ensure_approved_trader
  
  def dashboard
    @total_portfolio_value = current_trader.total_portfolio_value
    @recent_transactions = current_trader.transactions.includes(:stock).recent.limit(5)
    @top_stocks = current_trader.portfolios.joins(:stock).limit(5)
    @pending_transactions = current_trader.transactions.pending_approval.recent.limit(5) if defined?(current_trader.transactions.pending_approval)
    @trader = Trader.includes(comments: :admin_user).find(current_trader.id)
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
  end
  
  def buy_stock
    @stock = Stock.find(params[:stock_id])
    quantity = params[:quantity].to_i
    
    Rails.logger.info "=== BUY STOCK DEBUG ==="
    Rails.logger.info "Stock: #{@stock.symbol}"
    Rails.logger.info "Quantity: #{quantity}"
    Rails.logger.info "Price: #{@stock.current_price}"
    Rails.logger.info "Trader: #{current_trader.email}"
    
    if quantity <= 0
      redirect_back(fallback_location: "/traders/#{current_trader.id}/dashboard", alert: 'Invalid quantity')
      return
    end
    
    transaction = current_trader.transactions.build(
      stock: @stock,
      transaction_type: :buy,
      quantity: quantity,
      price: @stock.current_price,
      status: :pending
    )
    
    Rails.logger.info "Transaction valid: #{transaction.valid?}"
    Rails.logger.info "Transaction errors: #{transaction.errors.full_messages}" if !transaction.valid?
    
    if transaction.save
      Rails.logger.info "Transaction saved successfully"
      redirect_to "/traders/#{current_trader.id}/dashboard", 
                  notice: 'Buy order submitted! Waiting for admin approval.'
    else
      Rails.logger.error "Transaction save failed: #{transaction.errors.full_messages}"
      redirect_back(fallback_location: "/traders/#{current_trader.id}/dashboard", 
                   alert: "Failed to submit buy order: #{transaction.errors.full_messages.join(', ')}")
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