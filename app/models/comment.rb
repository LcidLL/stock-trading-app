class Comment < ApplicationRecord
  belongs_to :trader
  belongs_to :admin_user
end
