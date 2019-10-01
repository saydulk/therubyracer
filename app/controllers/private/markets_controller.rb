module Private
  class MarketsController < BaseController

    # before_action :auth_member!, only: [:show]
    skip_before_filter :auth_member!
    before_action :visible_market?, only: [:show]
    after_action :set_default_market, only: [:show]
    before_action :set_favorites_market, only: %w(show search show_all_markets)
    skip_filter *_process_action_callbacks.map(&:filter), only: :set_market_price
    layout false

    def show
      @bid = params[:bid]
      @ask = params[:ask]

      @markets = Market.all.sort
      @market_groups = @markets.map(&:quote_unit).uniq

      @bids = @market.bids
      @asks = @market.asks
      @trades = @market.trades
      # default to limit order
      @order_bid = OrderBid.new ord_type: 'limit'
      @order_ask = OrderAsk.new ord_type: 'limit'

      @decimal_dropdown ,@set_decimal = generate_decimal_dropdown
      @order_bid_market = OrderBid.new ord_type: 'market'
      @order_ask_market = OrderAsk.new ord_type: 'market'
      set_member_data if current_user
      gon.jbuilder
    end

    def search
      @search_page = params[:search_page]
      @markets = Market.search(params[:search])
      @tab_active =  params[:tab_active]
    end


    def show_all_markets
      @search_page = params[:search_page]
      @all_markets = Market.all.sort
    end

    def set_favorites
      set_favorite_market(params[:id], params[:type])
      render nothing: true, status: :ok
    end

    def set_market_price
      set_btc_and_dollar_price
      render nothing: true
    end

    private

    def visible_market?
      redirect_to market_path(Market.first) if not current_market.visible?
    end

    def set_default_market
      cookies[:market_id] = @market.id
    end

    def set_member_data
      @member = current_user
      orders = @member.orders.order("updated_at desc")
      @orders_wait = orders.with_currency(@market).with_state(:wait)
      @trades_done = Trade.for_member(@market.id, current_user, limit: 100, order: 'id desc')
      history_cancel = orders.includes(:trades).without_state('wait')
      @orders_history = history_cancel.where('updated_at BETWEEN ? AND ?', (Time.now - 24.hours), Time.now).order("created_at DESC").page(params[:page])
      @all_history = @orders_history.length
      # @orders = orders.where.not(state: 'done').order('id desc')
    end

    def set_favorite_market(market, op_type)
      existing_markets = cookies[:favorites].to_s.split(',')
      if op_type.eql?('add')
        Favorite.find_or_create_by(member_id: current_user.id, market_id: params[:id]) if current_user
        cookies[:favorites] = existing_markets.push(market).uniq.join(',')
      elsif op_type.eql?('remove')
        existing_markets.delete(market)
        Favorite.find_by(member_id: current_user.id, market_id: params[:id])&.destroy if current_user
        cookies[:favorites] = existing_markets.uniq.join(',')
      end
    end

    def set_favorites_market
      @market = current_market
      @favorites = current_user ? current_user.favorites.map(&:market_id) : cookies[:favorites].to_s.split(',')
    end

    def generate_decimal_dropdown
       decimal_value  = @market.bid['fixed']
       range_dropdown = decimal_value > 3 ? (decimal_value - 3 .. decimal_value).to_a : (0 .. decimal_value).to_a
       dropdown_list = []
       range_dropdown.each do |x|
         dropdown_list << [t('private.markets.show.text', num: x ) , x]
       end
       [dropdown_list, decimal_value]
    end
  end
end
