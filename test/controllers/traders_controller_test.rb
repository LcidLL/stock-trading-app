require "test_helper"

class TradersControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get traders_dashboard_url
    assert_response :success
  end

  test "should get portfolio" do
    get traders_portfolio_url
    assert_response :success
  end

  test "should get transactions" do
    get traders_transactions_url
    assert_response :success
  end

  test "should get buy_stock" do
    get traders_buy_stock_url
    assert_response :success
  end

  test "should get sell_stock" do
    get traders_sell_stock_url
    assert_response :success
  end
end
