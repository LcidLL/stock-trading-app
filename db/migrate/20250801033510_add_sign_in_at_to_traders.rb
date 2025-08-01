class AddSignInAtToTraders < ActiveRecord::Migration[7.2]
  def change
    add_column :traders, :last_sign_in_at, :datetime
  end
end
