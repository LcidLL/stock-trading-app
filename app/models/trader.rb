class Trader < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable

  has_many :transactions, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :stocks, through: :portfolios

  enum status: { pending: 0, approved: 1, rejected: 2 }

  def active_for_authentication?
    super && approved?
  end

  def inactive_message
    approved? ?super : :not_approved
  end

  def total_portfolio_value
    portfolios.sum { |portfolio| portfolio.quantity * portfolio.stock.current_price }
  end
end
