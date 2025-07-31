stocks = [
  { symbol: 'AAPL', name: 'Apple Inc.', current_price: 150.25 },
  { symbol: 'GOOGL', name: 'Alphabet Inc.', current_price: 2500.00 },
  { symbol: 'MSFT', name: 'Microsoft Corporation', current_price: 300.75 },
  { symbol: 'TSLA', name: 'Tesla Inc.', current_price: 250.50 },
  { symbol: 'AMZN', name: 'Amazon.com Inc.', current_price: 3200.00 }
]

stocks.each do |stock_attrs|
  Stock.find_or_create_by(symbol: stock_attrs[:symbol]) do |stock|
    stock.name = stock_attrs[:name]
    stock.current_price = stock_attrs[:current_price]
  end
end

puts "Created #{Stock.count} stocks"

# Create approved trader
trader = Trader.find_or_create_by(email: 'trader@example.com') do |t|
  t.password = 'password123'
  t.password_confirmation = 'password123'
  t.confirmed_at = Time.current  # Confirm the trader
end

# Ensure it's approved and confirmed (in case it already existed)
trader.update!(status: 'approved', confirmed_at: Time.current)
puts "Created/updated trader: #{trader.email} - Status: #{trader.status} - Confirmed: #{trader.confirmed?}"

# Create admin
admin = AdminUser.find_or_create_by(email: 'admin@example.com') do |a|
  a.password = 'password123'
  a.password_confirmation = 'password123'
end

puts "Created admin: #{admin.email}"

# Create some approved/completed transactions to show portfolio
puts "\nCreating sample transactions..."

# Get stock references
aapl = Stock.find_by(symbol: 'AAPL')
googl = Stock.find_by(symbol: 'GOOGL')
msft = Stock.find_by(symbol: 'MSFT')
tsla = Stock.find_by(symbol: 'TSLA')

# Create completed buy transactions (these will show in portfolio)
completed_transactions = [
  {
    stock: aapl,
    transaction_type: :buy,
    quantity: 10,
    price: 145.00,
    status: :completed,
    created_at: 3.days.ago
  },
  {
    stock: googl,
    transaction_type: :buy,
    quantity: 2,
    price: 2450.00,
    status: :completed,
    created_at: 2.days.ago
  },
  {
    stock: msft,
    transaction_type: :buy,
    quantity: 5,
    price: 295.50,
    status: :completed,
    created_at: 1.day.ago
  },
  {
    stock: tsla,
    transaction_type: :buy,
    quantity: 8,
    price: 240.00,
    status: :completed,
    created_at: 4.hours.ago
  }
]

completed_transactions.each do |trans_attrs|
  transaction = trader.transactions.find_or_create_by(
    stock: trans_attrs[:stock],
    transaction_type: trans_attrs[:transaction_type],
    quantity: trans_attrs[:quantity],
    price: trans_attrs[:price]
  ) do |t|
    t.status = trans_attrs[:status]
    t.created_at = trans_attrs[:created_at]
    # total_amount will be calculated by the before_validation callback
  end
  
  # Ensure it's completed
  transaction.update!(status: :completed, created_at: trans_attrs[:created_at])
  puts "Created transaction: #{trans_attrs[:transaction_type]} #{trans_attrs[:quantity]} shares of #{trans_attrs[:stock].symbol}"
end

# Create portfolios for the completed transactions
puts "\nCreating portfolio entries..."

portfolio_data = [
  {
    stock: aapl,
    quantity: 10,
    average_price: 145.00
  },
  {
    stock: googl,
    quantity: 2,
    average_price: 2450.00
  },
  {
    stock: msft,
    quantity: 5,
    average_price: 295.50
  },
  {
    stock: tsla,
    quantity: 8,
    average_price: 240.00
  }
]

portfolio_data.each do |portfolio_attrs|
  portfolio = trader.portfolios.find_or_create_by(stock: portfolio_attrs[:stock]) do |p|
    p.quantity = portfolio_attrs[:quantity]
    p.average_price = portfolio_attrs[:average_price]
  end
  
  # Update if it already existed
  portfolio.update!(
    quantity: portfolio_attrs[:quantity],
    average_price: portfolio_attrs[:average_price]
  )
  
  puts "Created portfolio: #{portfolio_attrs[:quantity]} shares of #{portfolio_attrs[:stock].symbol} @ $#{portfolio_attrs[:average_price]}"
end

# Create a few pending transactions to show the approval flow
puts "\nCreating pending transactions..."

pending_transactions = [
  {
    stock: aapl,
    transaction_type: :buy,
    quantity: 5,
    price: aapl.current_price,
    status: :pending
  },
  {
    stock: tsla,
    transaction_type: :sell,
    quantity: 3,
    price: tsla.current_price,
    status: :pending
  }
]

pending_transactions.each do |trans_attrs|
  transaction = trader.transactions.create!(
    stock: trans_attrs[:stock],
    transaction_type: trans_attrs[:transaction_type],
    quantity: trans_attrs[:quantity],
    price: trans_attrs[:price],
    status: trans_attrs[:status]
  )
  
  puts "Created pending transaction: #{trans_attrs[:transaction_type]} #{trans_attrs[:quantity]} shares of #{trans_attrs[:stock].symbol}"
end

puts "\n=== SEED DATA SUMMARY ==="
puts "Stocks: #{Stock.count}"
puts "Traders: #{Trader.count}"
puts "Admins: #{AdminUser.count}"
puts "Transactions: #{Transaction.count}"
puts "- Completed: #{Transaction.where(status: :completed).count}"
puts "- Pending: #{Transaction.where(status: :pending).count}"
puts "Portfolio entries: #{Portfolio.count}"

# Calculate total portfolio value
total_value = trader.reload.total_portfolio_value
puts "Trader's total portfolio value: $#{total_value}"