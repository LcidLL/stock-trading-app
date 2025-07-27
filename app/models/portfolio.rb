class Portfolio < ApplicationRecord
  belongs_to :trader
  belongs_to :stock

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :average_price, presence: true, numericality: { greater_than: 0 }
  validates :trader_id, uniqueness: { scope: :stock_id }

  def current_value
    quantity * stock.current_price
  end

  def profit_loss
    current_value - (quantity * average_price)
  end

  def profit_loss_percentage
    return 0 if average_price.zero?
    ((stock.current_price - average_price) / average_price) * 100
  end
end
