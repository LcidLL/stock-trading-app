class Portfolio < ApplicationRecord
  belongs_to :trader
  belongs_to :stock
end
