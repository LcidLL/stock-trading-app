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
end

# Ensure it's approved (in case it already existed)
trader.update!(status: 'approved')
puts "Created/updated trader: #{trader.email} - Status: #{trader.status}"

# Create admin
admin = AdminUser.find_or_create_by(email: 'admin@example.com') do |a|
  a.password = 'password123'
  a.password_confirmation = 'password123'
end

puts "Created admin: #{admin.email}"