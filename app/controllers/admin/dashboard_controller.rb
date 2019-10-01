module Admin
  class DashboardController < BaseController
    skip_load_and_authorize_resource

    before_action :set_currency_summary, only: [:index, :dashboard_csv]

    def index
      @register_count = Member.count
      respond_to do |format|
        format.html
        format.json { render json: DashboardDatatable.new(params) }
      end
    end

    def dashboard_csv
      fname = ''
      if params[:type] == 'full'
        fname = 'dashboard'
        data = @currencies_summary
      else
        fname = 'dashboard_24'
        data = @currencies_24_summary
      end
      send_data Currency.export(data),
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{fname}.csv"
    end

    private

    def set_currency_summary
      @currencies_summary = Currency.all.map(&:summary)
      @currencies_24_summary = Currency.all.map(&:summary_24)
    end

  end
end
