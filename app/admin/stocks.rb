ActiveAdmin.register Stock do
  permit_params :symbol, :name, :current_price

  filter :symbol
  filter :name
  filter :created_at

  index do
    selectable_column
    id_column
    column :symbol
    column :name
    column :current_price
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Stock Details" do
      f.input :symbol, label: "Stock Symbol"
      f.input :name, label: "Company Name"
      f.input :current_price, label: "Current Price", min: 0.01
    end
    f.actions
  end
end