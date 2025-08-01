class AddStatusToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :status, :integer, default: 0
  end
end
