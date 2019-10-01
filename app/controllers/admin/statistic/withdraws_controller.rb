module Admin
  module Statistic
    class WithdrawsController < BaseController
      def show
        @withdraws_grid = ::Statistic::WithdrawsGrid.new(params[:statistic_withdraws_grid])

        respond_to do |f|
          f.html do
            @withdraws_grid.scope {|scope| scope.page(params[:page]).per(20) }
            @assets = @withdraws_grid.assets

            @groups = {
                :count => @assets.all.size,
                :amount => @assets.sum(:amount),
                :fee => @assets.sum(:fee)
            }
            @chart = set_dynamic_charts(@assets, 'created_at', :long, 'Withdraw History ', { amount: 'amount' })

          end
          f.csv do
            send_data @withdraws_grid.to_csv,
                      type: "text/csv",
                      disposition: 'inline',
                      filename: "grid-#{Time.now.to_s}.csv"
          end
        end

      end
    end
  end
end
