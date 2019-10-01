module Admin
  class MembersController < BaseController
    load_and_authorize_resource

    def index
      @search_field = params[:search_field]
      @search_term = params[:search_term]
      @members = Member.search(field: @search_field, term: @search_term).page params[:page]
    end

    def show
      @account_versions = AccountVersion.where(account_id: @member.account_ids).order(:id).reverse_order.page params[:page]
    end

    def toggle
      if params[:api]
        @member.api_disabled = !@member.api_disabled?
      else
        @member.disabled = !@member.disabled?
      end
      @member.save!
    end


    def active
      @member.update_attribute(:activated, true)
      @member.save
      redirect_to admin_member_path(@member),notice:  'Email has been activated'
    end

    def liquidity
      @records = []
       %w(BITTREX).each do |exchange|
         @records.push({exchange: exchange, user: ENV["#{exchange}_USER"]})
       end
      @currencies = Currency.all.map(&:code)
    end

    def commission
      fake_ids = Member.where(is_fake: true).ids
      @account_versions = AccountVersion.where.not(member_id: fake_ids).select('id, currency, sum(fee) as total_fees , modifiable_type as modifiable_type').group('currency, modifiable_type').where(modifiable_type: ['Withdraw','Trade'])
      # @commissions = Withdraw.select('currency, sum(fee) as total_fees').where("aasm_state = ? AND txid IS NOT NULL ", 'done').group('currency')
      @commissions = @account_versions.where(modifiable_type:'Withdraw')
      @commission_trades = @account_versions.where(modifiable_type:'Trade')
      @commission_list = Commission.select('currency, sum(amount) as total_commission , modifiable_type as modifiable_type').group('currency,modifiable_type').where(modifiable_type: ['Withdraw','Trade'])

      @trades_grid = ::Statistic::CommissionsGrid.new(params[:statistic_commissions_grid])do |scope|
        scope.page(params[:page])
      end
      @assets = @trades_grid.assets
      # @history_withdraw = Commission.where(modifiable_type: 'Withdraw')
      # @history_trade = Commission.where(modifiable_type: 'Trade')
      render json: { fee: @commissions.where(currency: params[:currency]).first&.total_fees } if params.has_key?'currency'
    end
  end
end
