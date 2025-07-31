ActiveAdmin.register Transaction do
  filter :trader, collection: -> { Trader.approved.order(:email) }
  filter :stock
  filter :transaction_type, as: :select, collection: [['Buy', 'buy'], ['Sell', 'sell']]
  filter :status, as: :select, collection: [['Pending', 'pending'], ['Approved', 'approved'], ['Completed', 'completed'], ['Rejected', 'rejected'], ['Failed', 'failed']]
  filter :created_at
  filter :total_amount

  scope :all
  scope :pending, default: true
  scope :approved
  scope :completed
  scope :rejected

  index do
    selectable_column
    id_column
    
    column "Trader" do |transaction|
      link_to transaction.trader.email, admin_trader_path(transaction.trader)
    end
    
    column "Stock" do |transaction|
      "#{transaction.stock.symbol} - #{transaction.stock.name}"
    end
    
    column "Type" do |transaction|
      type_text = case transaction.transaction_type
                 when 'buy', 0, nil then 'Buy'
                 when 'sell', 1 then 'Sell'
                 else 'Unknown'
                 end
      
      status_tag type_text, class: type_text.downcase == 'buy' ? 'ok' : 'error'
    end
    
    column :quantity
    column "Price" do |transaction|
      number_to_currency(transaction.price)
    end
    
    column "Total Amount" do |transaction|
      number_to_currency(transaction.total_amount)
    end
    
    column "Status" do |transaction|
      status_text = case transaction.status
                   when 'pending', 0, nil then 'Pending'
                   when 'approved', 1 then 'Approved'
                   when 'completed', 2 then 'Completed'
                   when 'rejected', 3 then 'Rejected'
                   when 'failed', 4 then 'Failed'
                   else 'Unknown'
                   end
      
      status_class = case status_text.downcase
                    when 'pending' then 'warning'
                    when 'approved', 'completed' then 'ok'
                    when 'rejected', 'failed' then 'error'
                    else 'default'
                    end
      
      status_tag status_text, class: status_class
    end
    
    column :created_at
    
    column "Actions" do |transaction|
      is_pending = case transaction.status
                  when 'pending', 0, nil then true
                  else false
                  end
      
      if is_pending
        transaction_type = case transaction.transaction_type
                          when 'buy', 0, nil then 'buy'
                          when 'sell', 1 then 'sell'
                          else 'transaction'
                          end
        
        link_to("Approve", approve_admin_transaction_path(transaction), 
                method: :patch, class: "button", 
                data: { confirm: "Are you sure you want to approve this #{transaction_type}?" }) + " " +
        link_to("Reject", reject_admin_transaction_path(transaction), 
                method: :patch, class: "button", 
                data: { confirm: "Are you sure you want to reject this #{transaction_type}?" })
      else
        current_status = case transaction.status
                        when 'pending', 0, nil then 'Pending'
                        when 'approved', 1 then 'Approved'
                        when 'completed', 2 then 'Completed'
                        when 'rejected', 3 then 'Rejected'
                        when 'failed', 4 then 'Failed'
                        else 'Unknown'
                        end
        status_tag current_status
      end
    end
    
    actions
  end

  show do
    attributes_table do
      row :id
      row("Trader") { |t| link_to t.trader.email, admin_trader_path(t.trader) }
      row("Stock") { |t| "#{t.stock.symbol} - #{t.stock.name}" }
      row("Current Stock Price") { |t| number_to_currency(t.stock.current_price) }
      row("Transaction Type") { |t| t.transaction_type&.capitalize || 'Unknown' }
      row :quantity
      row("Price per Share") { |t| number_to_currency(t.price) }
      row("Total Amount") { |t| number_to_currency(t.total_amount) }
      row("Status") { |t| status_tag(t.status&.capitalize || 'Unknown') }
      row :created_at
      row :updated_at
    end

    if transaction.transaction_type == 'sell'
      panel "Trader's Current Holdings" do
        portfolio = transaction.trader.portfolios.find_by(stock: transaction.stock)
        if portfolio
          attributes_table_for portfolio do
            row("Current Quantity") { portfolio.quantity }
            row("Average Price") { number_to_currency(portfolio.average_price) }
            row("Current Value") { number_to_currency(portfolio.current_value) }
            row("Profit/Loss") do
              amount = portfolio.profit_loss
              color = amount >= 0 ? 'green' : 'red'
              content_tag :span, number_to_currency(amount), style: "color: #{color};"
            end
          end
        else
          para "Trader does not currently own this stock."
        end
      end
    end

    active_admin_comments
  end

  member_action :approve, method: :patch do
    begin
      resource.approve!
      Rails.logger.info "Transaction #{resource.id} approved by admin"
      redirect_to admin_transactions_path, notice: "Transaction approved successfully!"
    rescue => e
      Rails.logger.error "Failed to approve transaction #{resource.id}: #{e.message}"
      redirect_to admin_transactions_path, alert: "Failed to approve transaction: #{e.message}"
    end
  end

  member_action :reject, method: :patch do
    begin
      resource.reject!
      Rails.logger.info "Transaction #{resource.id} rejected by admin"
      redirect_to admin_transactions_path, notice: "Transaction rejected."
    rescue => e
      Rails.logger.error "Failed to reject transaction #{resource.id}: #{e.message}"
      redirect_to admin_transactions_path, alert: "Failed to reject transaction: #{e.message}"
    end
  end

  # Batch actions
  batch_action :approve, confirm: "Are you sure you want to approve these transactions?" do |ids|
    approved_count = 0
    failed_count = 0
    
    Transaction.find(ids).each do |transaction|
      if transaction.status == 'pending'
        begin
          transaction.approve!
          approved_count += 1
        rescue => e
          Rails.logger.error "Failed to approve transaction #{transaction.id}: #{e.message}"
          failed_count += 1
        end
      end
    end
    
    message = "#{approved_count} transactions approved"
    message += ", #{failed_count} failed" if failed_count > 0
    redirect_to collection_path, notice: message
  end

  batch_action :reject, confirm: "Are you sure you want to reject these transactions?" do |ids|
    rejected_count = 0
    
    Transaction.where(id: ids, status: 'pending').each do |transaction|
      transaction.reject!
      rejected_count += 1
    end
    
    redirect_to collection_path, notice: "#{rejected_count} transactions rejected"
  end

  form do |f|
    f.inputs "Transaction Details" do
      f.input :trader, collection: Trader.approved.order(:email)
      f.input :stock, collection: Stock.order(:symbol)
      f.input :transaction_type, as: :select, collection: [['Buy', 'buy'], ['Sell', 'sell']]
      f.input :quantity
      f.input :price
      f.input :status, as: :select, collection: [['Pending', 'pending'], ['Approved', 'approved'], ['Completed', 'completed'], ['Rejected', 'rejected'], ['Failed', 'failed']]
    end
    f.actions
  end

  permit_params :trader_id, :stock_id, :transaction_type, :quantity, :price, :status

  csv do
    column :id
    column("Trader Email") { |t| t.trader.email }
    column("Stock Symbol") { |t| t.stock.symbol }
    column("Stock Name") { |t| t.stock.name }
    column :transaction_type
    column :quantity
    column :price
    column :total_amount
    column :status
    column :created_at
    column :updated_at
  end
end