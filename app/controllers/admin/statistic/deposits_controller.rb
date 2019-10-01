module Admin
  module Statistic
    class DepositsController < BaseController
      prepend_before_filter :load_grid

      def show
        @deposits_grid = ::Statistic::DepositsGrid.new(params[:statistic_deposits_grid])

        respond_to do |f|
          f.html do
            @deposits_grid.scope {|scope| scope.page(params[:page]).per(20) }
            @assets = @deposits_grid.assets

            @groups = {
                :count => @assets.all.size,
                :amount => @assets.sum(:amount)
            }
            @chart = set_dynamic_charts(@assets, 'created_at', :long, 'Deposit History ', { amount: 'amount' })

          end
          f.csv do
            send_data @deposits_grid.to_csv,
                      type: "text/csv",
                      disposition: 'inline',
                      filename: "grid-#{Time.now.to_s}.csv"
          end
        end

      end

      private
      def load_grid
        @deposits_grid = ::Statistic::DepositsGrid.new(params[:statistic_deposits_grid])
        @assets = @deposits_grid.assets
      end
    end
  end
end
