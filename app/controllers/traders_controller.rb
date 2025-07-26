class TradersController < ApplicationController
  before_action :authenticate_trader!
  before_action :ensure_approved_trader
  
  def dashboard
    @total_portfolio_value = current_trader.total_portfolio_value
    @recent_transactions = current_trader.transactions.order(created_at: :desc).limit(5)
    @top_stocks = current_trader.portfolios.joins(:stock).limit(5)
  end
  
  def portfolio
    @portfolios = current_trader.portfolios.includes(:stock).where('quantity > 0')
    @total_value = @portfolios.sum(&:current_value)
    @total_profit_loss = @portfolios.sum(&:profit_loss)
  end
  
  def transactions
    @transactions = current_trader.transactions.includes(:stock).order(created_at: :desc)
    @transactions = @transactions.where(transaction_type: params[:type]) if params[:type].present?
    @transactions = @transactions.page(params[:page])
  end
  
  def buy_stock
    @stock = Stock.find(params[:stock_id])
    quantity = params[:quantity].to_i
    
    if quantity <= 0
      redirect_back(fallback_location: traders_dashboard_path, alert: 'Invalid quantity')
      return
    end
    
    transaction = current_trader.transactions.build(
      stock: @stock,
      transaction_type: :buy,
      quantity: quantity,
      price: @stock.current_price,
      status: :completed
    )
    
    if transaction.save
      update_portfolio_after_buy(transaction)
      redirect_to traders_dashboard_path(current_trader), notice: 'Stock purchased successfully!'
    else
      redirect_back(fallback_location: traders_dashboard_path, alert: 'Failed to purchase stock')
    end
  end
  
  def sell_stock
    @stock = Stock.find(params[:stock_id])
    quantity = params[:quantity].to_i
    portfolio = current_trader.portfolios.find_by(stock: @stock)
    
    if !portfolio || portfolio.quantity < quantity
      redirect_back(fallback_location: traders_portfolio_path(current_trader), alert: 'Insufficient stocks to sell')
      return
    end
    
    transaction = current_trader.transactions.build(
      stock: @stock,
      transaction_type: :sell,
      quantity: quantity,
      price: @stock.current_price,
      status: :completed
    )
    
    if transaction.save
      update_portfolio_after_sell(transaction, portfolio)
      redirect_to traders_portfolio_path(current_trader), notice: 'Stock sold successfully!'
    else
      redirect_back(fallback_location: traders_portfolio_path(current_trader), alert: 'Failed to sell stock')
    end
  end
  
  private
  
  def ensure_approved_trader
    unless current_trader.approved?
      sign_out(current_trader)
      redirect_to root_path, alert: 'Your account is pending approval. Please wait for admin approval.'
    end
  end
  
  def update_portfolio_after_buy(transaction)
    portfolio = current_trader.portfolios.find_or_initialize_by(stock: transaction.stock)
    
    if portfolio.persisted?
      total_cost = (portfolio.quantity * portfolio.average_price) + transaction.total_amount
      total_quantity = portfolio.quantity + transaction.quantity
      portfolio.update!(
        quantity: total_quantity,
        average_price: total_cost / total_quantity
      )
    else
      portfolio.update!(
        quantity: transaction.quantity,
        average_price: transaction.price
      )
    end
  end
  
  def update_portfolio_after_sell(transaction, portfolio)
    new_quantity = portfolio.quantity - transaction.quantity
    
    if new_quantity > 0
      portfolio.update!(quantity: new_quantity)
    else
      portfolio.destroy
    end
  end
end