class AddStatusToTraders < ActiveRecord::Migration[7.2]
  def change
    add_column :traders, :status, :integer, default: 0
    add_index :traders, :status
  end
end