class User < ApplicationRecord

  has_secure_password

  enum :role, { pending_role: 0, trader: 1, admin: 2 }
  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :email, presence: true, uniqueness: true
  

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= :pending
  end

end