class Trader < ApplicationRecord
  # Add :confirmable back
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_many :transactions, dependent: :destroy
  has_many :portfolios, dependent: :destroy
  has_many :stocks, through: :portfolios
  has_many :comments

  enum status: { pending: 0, approved: 1, rejected: 2 }

  def active_for_authentication?
    super && approved? && confirmed?
  end

  def inactive_message
    if !confirmed?
      :unconfirmed
    elsif !approved?
      :not_approved
    else
      super
    end
  end

  def total_portfolio_value
    portfolios.sum { |portfolio| portfolio.quantity * portfolio.stock.current_price }
  end

  #for ransack error
  def self.ransackable_associations(auth_object = nil)
    ["transactions", "portfolios"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["email", "status", "created_at", "updated_at", "confirmed_at", "confirmation_sent_at"]
  end
end