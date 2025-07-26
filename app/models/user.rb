class User < ApplicationRecord
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { pending: 0, trader: 1, admin: 2 }

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create 
  validates :password_confirmation, presence: true, on: :create

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :pending
  end

  def admin?
    self.role == 'admin' || self.role == :admin
  end

  def trader?
    self.role == 'trader' || self.role == :trader
  end

  def pending?
    self.role == 'pending' || self.role == :pending
  end

  # has_many :transactions
  # has_one :portfolio
end