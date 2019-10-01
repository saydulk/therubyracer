module Admin
  module Statistic
    class TradesController < BaseController
      def show
        @trades_grid = ::Statistic::TradesGrid.new(params[:statistic_trades_grid])

        respond_to do |f|
          f.html do
            @trades_grid.scope {|scope| scope.page(params[:page]).per(20) }
            @assets = @trades_grid.assets

            @groups = {
                :volume => @assets.sum(:volume),
                :amount => @assets.map{ |t| t.price * t.volume }.sum,
                :avg_price => @assets.average(:price),
                :max_price => @assets.maximum(:price),
                :min_price => @assets.minimum(:price)
            }

            @groups.merge!({
                               :volume_fee => (@groups[:volume]),
                               :amount_fee => (@groups[:amount]),
                               :count => @assets.all.size
                           })

            @chart = set_dynamic_charts(@assets, 'created_at', :long, 'Orders Placed', { price: 'price', volume: 'volume' })
          end

          f.csv do
            send_data @trades_grid.to_csv,
                      type: "text/csv",
                      disposition: 'inline',
                      filename: "grid-#{Time.now.to_s}.csv"
          end
        end
























      end
    end
  end
end
