ActiveAdmin.register Trader do
  filter :email
  filter :status, as: :select, collection: Trader.statuses.keys.map { |s| [s.humanize, s] }
  filter :created_at

  index do
    selectable_column
    id_column
    column :email
    column :status do |trader|
      status_tag trader.status
    end
    column :created_at
    column :updated_at
    column "Portfolios" do |trader|
      trader.portfolios.map(&:name).join(", ").html_safe
    end
    actions
  end

  form do |f|
    f.inputs "Trader Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :status, as: :select, collection: Trader.statuses.keys.map { |s| [s.humanize, s] }
    end
    f.actions
  end

  permit_params :email, :password, :password_confirmation, :status
end