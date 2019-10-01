module Private
  class HistoryController < BaseController

    helper_method :tabs

    def account
      @market = current_market
      # @deposits = Deposit.where(member: current_user).with_aasm_state(:collected).page(params[:page]).per(20)
      @deposits = Deposit.where(member: current_user).where(aasm_state: ["accepted","collected"]).page(params[:page]).per(20)
      @withdraws = Withdraw.where(member: current_user).with_aasm_state(:done)

      @transactions = (@deposits + @withdraws).sort_by {|t| -t.created_at.to_i }
      @transactions = Kaminari.paginate_array(@transactions).page(params[:page]).per(20)
    end

    def download_csv
      history_entity = params[:type].eql?('withdrawl') ?  Withdraw.where(member: current_user).with_aasm_state(:done) : Deposit.where(member: current_user).with_aasm_state(:collected)
      respond_to do |format|
        format.html
        format.csv { send_data  history_entity.write_date_csv }
      end
    end
    def trades
      @currency = Currency.all
      @start_date = params[:start_date]
      @end_date= params[:end_date]
      @trades = current_user.trades
        .includes(:ask_member).includes(:bid_member)
        .order('id desc').page(params[:page]).per(20)
      if params[:side].present?
        if params[:side].casecmp('Sell') == 0
          @trades = @trades.where(ask_member_id: current_user.id)
        elsif params[:side].casecmp('BUY') == 0
          @trades = @trades.where(bid_member_id: current_user.id)
        end
      end
      if params[:currency] || params[:market].present?
        concat_pair = params[:currency] + params[:market]
        @trades = params[:market].present? ? @trades.where( currency: concat_pair.downcase) : @trades.where( ask: concat_pair.downcase)
      end
      @trades = @trades.where('DATE(created_at) >=? AND DATE(created_at) <= ?' ,@start_date.to_date, @end_date.to_date) if @start_date.present? && @end_date.present?
    end

    def orders
      @currency = Currency.all
      @start_date = params[:start_date]
      @end_date= params[:end_date]
      @orders = current_user.orders.includes(:trades).order("id desc").page(params[:page]).per(20)
      if params[:side].present?
        type = params[:side] == 'Sell' ? 'OrderAsk' : 'OrderBid'
        @orders = @orders.where(type: type)
      end

      if params[:currency] || params[:market].present?
        concat_pair = params[:currency] + params[:market]
        if params[:market].present?

          @orders= @orders.where( currency: concat_pair.downcase)
        else
          @orders= @orders.where( ask: concat_pair.downcase)
        end

      end
      @orders = @orders.where('DATE(created_at) >=? AND DATE(created_at) <= ?' ,@start_date.to_date, @end_date.to_date) if @start_date.present? && @end_date.present?

    end

    def open_orders
      @open_orders = current_user.orders.where(state: "wait").order("id desc").page(params[:page]).per(20)
    end

    private

    def tabs
      { open_order: ['header.open_order_history', open_order_history_path],
        order: ['header.order_history', order_history_path],
        trade: ['header.trade_history', trade_history_path]
        }
    end

  end
end
