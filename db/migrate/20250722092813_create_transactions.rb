class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :trader, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.string :transaction_type
      t.integer :quantity
      t.decimal :price
      t.decimal :total_amount
      t.string :status

      t.timestamps
    end
  end
end
