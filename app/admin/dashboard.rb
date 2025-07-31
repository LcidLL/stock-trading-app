ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Trader Registrations Over Time" do
          data = Trader.group_by_day(:created_at, last: 90).count
          line_chart data, curve: false, library: {
            title: "New Traders Last 90 Days",
            hAxis: { title: "Date" },
            vAxis: { title: "Number of Traders" },
            pointSize: 5
          }
        end
      end

      column do
        panel "Traders by Approval Status" do
          if Trader.column_names.include?('approved')
            data = Trader.group(:status).count
            pie_chart data, donut: true, library: {
              title: "Traders by Approval Status",
              pieHole: 0.4 
            }
          elsif Trader.column_names.include?('status')
            data = Trader.group(:status).count
            pie_chart data, donut: true, library: {
              title: "Traders by Account Status",
              pieHole: 0.4
            }
          else
            para "No 'approved' or 'status' column found on Trader model."
          end
        end
      end
    end # End of columns

    columns do
      column do
        panel "Traders with Recent Activity (Last 30 Days)" do
          # This assumes your Trader model has a 'last_sign_in_at' or 'last_activity_at' timestamp
          # Or, if you track trades, you could count traders who made trades recently
          if Trader.column_names.include?('last_sign_in_at')
            active_traders_data = Trader.where('last_sign_in_at >= ?', 30.days.ago)
                                        .group_by_day(:last_sign_in_at, last: 30)
                                        .count
            column_chart active_traders_data, library: {
              title: "Traders Active in Last 30 Days",
              hAxis: { title: "Date" },
              vAxis: { title: "Number of Active Traders" }
            }
          else
            para "No 'last_sign_in_at' column found on Trader model for activity tracking."
          end
        end
      end
    end

  end # content
end