ActiveAdmin.register Trader do
  filter :email
  filter :status, as: :select, collection: [['Pending', 'pending'], ['Approved', 'approved'], ['Rejected', 'rejected']]
  filter :created_at

  index do
    selectable_column
    id_column
    column :email
    column "Status" do |trader|
      trader.status || "pending"
    end
    column "Email Confirmed" do |trader|
      trader.confirmed_at.present? ? "Yes" : "No"
    end
    column :created_at
    column "Actions" do |trader|
      if trader.status == "pending"
        link_to("Approve", approve_admin_trader_path(trader), method: :patch, class: "button") + " " +
        link_to("Reject", reject_admin_trader_path(trader), method: :patch, class: "button")
      else
        trader.status.capitalize
      end
    end
    actions
  end

  form do |f|
    f.inputs "Trader Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :status, as: :select, collection: [['Pending', 'pending'], ['Approved', 'approved'], ['Rejected', 'rejected']]
    end
    f.actions
  end

  member_action :approve, method: :patch do
    resource.update!(status: :approved)
    redirect_to admin_traders_path, notice: "Trader #{resource.email} has been approved and can now login."
  end

  member_action :reject, method: :patch do
    resource.update!(status: :rejected)
    redirect_to admin_traders_path, notice: "Trader #{resource.email} has been rejected."
  end

  permit_params :email, :password, :password_confirmation, :status
end