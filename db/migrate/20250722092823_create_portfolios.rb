class CreatePortfolios < ActiveRecord::Migration[7.2]
  def change
    create_table :portfolios do |t|
      t.references :trader, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :average_price

      t.timestamps
    end
  end
end
