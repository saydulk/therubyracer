
module Admin
  module Statistic
    class OrdersController < BaseController
      def show
        @orders_grid = ::Statistic::OrdersGrid.new(params[:statistic_orders_grid])

        respond_to do |f|
          f.html do
            @orders_grid.scope {|scope| scope.page(params[:page]).per(20) }
            @assets = @orders_grid.assets

            @groups = {
                :count => @assets.size,
                :sum => @assets.sum(:origin_volume),
                :avg => (@assets.average(:price) || 0.to_d).truncate(2),
                :sum_strike => @assets.all.map { |o| o.origin_volume - o.volume }.sum
            }

            @chart = set_dynamic_charts(@assets, 'created_at', :long, 'Orders Placed', { price: 'price', volume: 'origin_volume' })

          end
          f.csv do
            send_data @orders_grid.to_csv,
                      type: "text/csv",
                      disposition: 'inline',
                      filename: "grid-#{Time.now.to_s}.csv"
          end
        end
      end
    end
  end
end
