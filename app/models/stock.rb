class Stock < ApplicationRecord
  has_many :transactions, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :traders, through: :portfolios

  validates :symbol, presence: true, uniqueness: true
  validates :name, presence: true
  validates :current_price, presence: true, numericality: { greater_than: 0 }

  def self.available_for_trading
    where('current_price > 0')
  end
end
