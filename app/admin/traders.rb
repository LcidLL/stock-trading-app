ActiveAdmin.register Trader do
  filter :email
  filter :status, as: :select, collection: [['Pending', 'pending'], ['Approved', 'approved'], ['Rejected', 'rejected']]
  filter :created_at

  #scopes try
  scope :all, default: true
  scope :pending
  scope :approved
  scope :rejected

  #for approval
  member_action :approve, method: :put do
    trader = Trader.find(params[:id])
    trader.update(status: :approved)
    redirect_to admin_trader_path(trader), notice: "Trader has been approved."
  end

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
    actions do |trader|
      if trader.pending?
        item "Approve", approve_admin_trader_path(trader), method: :put, class: "member_link"
      end
    end
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

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :email
          row :status
          row :created_at
          row :updated_at
        end
      end

      column do
        panel "Admin Comments" do
          table_for trader.comments.order(created_at: :desc) do
            column :body
            column "Author", :admin_user do |comment|
              comment.admin_user.email
            end
            column :created_at
          end
          render 'admin/traders/comment_form', trader: trader
        end
      end
    end
  member_action :approve, method: :patch do
    resource.update!(status: :approved)
    
    # Send approval email
    begin
      TraderMailer.approval_notification(resource).deliver_now
      Rails.logger.info "Approval email sent to #{resource.email}"
    rescue => e
      Rails.logger.error "Failed to send approval email to #{resource.email}: #{e.message}"
    end
    
    redirect_to admin_traders_path, notice: "Trader #{resource.email} has been approved and notification email sent."
  end

  member_action :reject, method: :patch do
    resource.update!(status: :rejected)
    
    # Send rejection email
    begin
      TraderMailer.rejection_notification(resource).deliver_now
      Rails.logger.info "Rejection email sent to #{resource.email}"
    rescue => e
      Rails.logger.error "Failed to send rejection email to #{resource.email}: #{e.message}"
    end
    
    redirect_to admin_traders_path, notice: "Trader #{resource.email} has been rejected and notification email sent."
  end

  permit_params :email, :password, :password_confirmation, :status
end