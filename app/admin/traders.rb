ActiveAdmin.register Trader do
  filter :email
  filter :status, as: :select, collection: Trader.statuses.keys.map { |s| [s.humanize, s] }
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
    column :status do |trader|
      status_tag trader.status
    end
    column :created_at
    column :updated_at
    column "Portfolios" do |trader|
      trader.portfolios.map(&:name).join(", ").html_safe
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
      f.input :status, as: :select, collection: Trader.statuses.keys.map { |s| [s.humanize, s] }
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
  end

  permit_params :email, :password, :password_confirmation, :status
end