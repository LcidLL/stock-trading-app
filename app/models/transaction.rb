class Transaction < ApplicationRecord
  belongs_to :trader
  belongs_to :stock

  enum transaction_type: { buy: 0, sell: 1 }
  enum status: { pending: 0, completed: 1, failed: 2 }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_total_amount

  private

  def calculate_total_amount
    self.total_amount = quantity * price
  end
end
