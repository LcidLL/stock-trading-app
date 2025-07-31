module AdminPanel
  class DashboardController < ApplicationController
    before_action :authenticate_admin!

    def index
      trader_status_counts = User.trader.group(:status).count

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column('string', 'Status')
      data_table.new_column('number', 'Count')

      trader_status_counts.each do |status, count|
        display_status = status.to_s.capitalize
        data_table.add_row([display_status, count])
      end

      options = {
        width: 600,
        height: 400,
        title: 'Trader Status Distribution',
        is3D: true,
        pieHole: 0.4,
        legend: { position: 'labeled' },
        tooltip: { trigger: 'focus' },
      }

      @traders_chart = GoogleVisualr::Interactive::PieChart.new(data_table, options)

      @total_traders = User.trader.count
    end

    private

    def authenticate_admin!
      unless current_user && current_user.admin?
        redirect_to root_path, alert: "You are not authorized to access this page."
      end
    end
  end
end