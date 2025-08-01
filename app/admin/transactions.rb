ActiveAdmin.register Transaction do
  filter :trader, as: :select, collection: proc { Trader.pluck(:email, :id) }
  filter :stock, as: :select, collection: proc { Stock.pluck(:symbol, :id) }
  filter :transaction_type, as: :select, collection: Transaction.transaction_types.keys.map(&:titleize)
  filter :status, as: :select, collection: proc { Transaction.statuses.keys.map(&:titleize) }
  filter :created_at

  index do
    selectable_column
    id_column

    column :trader do |transaction|
      link_to transaction.trader.email, admin_trader_path(transaction.trader)
    end

    column :stock do |transaction|
      link_to transaction.stock.symbol, admin_stock_path(transaction.stock)
    end

    column :transaction_type
    column :quantity
    column :price
    column :status do |transaction|
      status_tag transaction.status
    end
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :trader
      row :stock
      row :transaction_type
      row :quantity
      row :price
      row :status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Transaction Details" do
      f.input :trader, as: :select, collection: Trader.order(:email).map { |t| [t.email, t.id] }
      f.input :stock, as: :select, collection: Stock.order(:symbol).map { |s| ["#{s.symbol} - #{s.name}", s.id] }
      f.input :transaction_type, as: :select, collection: Transaction.transaction_types.keys.map(&:titleize)
      f.input :quantity, min: 1
      f.input :price, min: 0.01
      f.input :status, as: :select, collection: Transaction.statuses.keys.map(&:titleize)
    end
    f.actions
  end
end