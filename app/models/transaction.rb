class Transaction < ApplicationRecord
  belongs_to :trader
  belongs_to :stock

  enum transaction_type: { buy: 0, sell: 1 }
  enum status: { pending: 0, approved: 1, completed: 2, rejected: 3, failed: 4 }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  before_validation :calculate_total_amount

  scope :pending_approval, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }

  def approve!
    update!(status: :approved)
    execute_transaction if approved?
  end

  def reject!
    update!(status: :rejected)
  end

  private

  def calculate_total_amount
    if quantity.present? && price.present?
      self.total_amount = quantity * price
    end
  end

  def execute_transaction
    case transaction_type
    when 'buy'
      execute_buy_transaction
    when 'sell'
      execute_sell_transaction
    end
  end

  def execute_buy_transaction
    portfolio = trader.portfolios.find_or_initialize_by(stock: stock)
    
    if portfolio.persisted?
      total_cost = (portfolio.quantity * portfolio.average_price) + total_amount
      total_quantity = portfolio.quantity + quantity
      portfolio.update!(
        quantity: total_quantity,
        average_price: total_cost / total_quantity
      )
    else
      portfolio.update!(
        quantity: quantity,
        average_price: price
      )
    end
    
    update!(status: :completed)
  end

  def execute_sell_transaction
    portfolio = trader.portfolios.find_by(stock: stock)
    
    if portfolio && portfolio.quantity >= quantity
      new_quantity = portfolio.quantity - quantity
      
      if new_quantity > 0
        portfolio.update!(quantity: new_quantity)
      else
        portfolio.destroy
      end
      
      update!(status: :completed)
    else
      update!(status: :failed)
    end
  end
end