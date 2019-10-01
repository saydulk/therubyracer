module APIv2
  class Orders < Grape::API
    helpers ::APIv2::NamedParams

    before { authenticate! }

    desc 'Get your orders, results is paginated.', scopes: %w(history trade)
    params do
      use :market
      optional :state, type: String,  default: 'wait', values: Order.state.values, desc: "Filter order by state, default to 'wait' (active orders)."
      optional :limit, type: Integer, default: 100, range: 1..1000, desc: "Limit the number of returned orders, default to 100."
      optional :page,  type: Integer, default: 1, desc: "Specify the page of paginated results."
      optional :order_by, type: String, values: %w(asc desc), default: 'asc', desc: "If set, returned orders will be sorted in specific order, default to 'asc'."
      # For filters
      optional :side, type: String, values: %w(sell buy), desc: "Filter order by order type, default to "
      optional :from, type: Date, desc: "Filter order by date"
      optional :to , type: Date, desc: "Filter order by date"
    end
    get "/orders" do
      orders = current_user.orders
                   .order(order_param)
                   .with_currency(current_market)
                   .with_state(params[:state])
                   .page(params[:page])
                   .per(params[:limit])
      if params[:side].present?
        type = params[:side] == 'sell' ? 'OrderAsk' : 'OrderBid'
        orders = orders.where(type: type)
      end
      orders = orders.where('created_at BETWEEN ? AND ?', params[:from].to_date, params[:to].to_date) if params[:from].present? && params[:to].present?

      present orders, with: APIv2::Entities::Order
    end

    desc 'Get information of specified order.', scopes: %w(history trade)
    params do
      use :order_id
    end
    get "/order" do
      order = current_user.orders.where(id: params[:id]).first
      raise OrderNotFoundError, params[:id] unless order
      present order, with: APIv2::Entities::Order, type: :full
    end

    desc 'Create multiple sell/buy orders.', scopes: %w(trade)
    params do
      use :market
      requires :orders, type: Array do
        use :order
      end
    end
    post "/orders/multi" do
      orders = create_orders params[:orders]
      present :message, 'Orders have been placed successfully.'
      present :orders, orders, with: APIv2::Entities::Order
    end

    desc 'Create a Sell/Buy order.', scopes: %w(trade)
    params do
      use :market, :order
    end
    post "/orders" do
      order = create_order params
      present :message, get_i18('orders','order_created')
    end

    desc 'Cancel an order.', scopes: %w(trade)
    params do
      use :order_id
    end
    post "/order/delete" do
      begin
        order = current_user.orders.find(params[:id])
        Ordering.new(order).cancel
        present :message, get_i18('orders','order_cancalled')
        present :order, order, with: APIv2::Entities::Order
      rescue
        raise CancelOrderError, $!
      end
    end

    desc 'Cancel all my orders.', scopes: %w(trade)
    params do
      optional :side, type: String, values: %w(sell buy), desc: "If present, only sell orders (asks) or buy orders (bids) will be canncelled."
    end
    post "/orders/clear" do
      begin
        orders = current_user.orders.with_state(:wait)
        if params[:side].present?
          type = params[:side] == 'sell' ? 'OrderAsk' : 'OrderBid'
          orders = orders.where(type: type)
        end
        orders.each {|o| Ordering.new(o).cancel }
        present :message, "All #{params[:side]} Orders has been cancelled successfully."
        present :orders, orders, with: APIv2::Entities::Order
      rescue
        raise CancelOrderError, $!
      end
    end

    desc 'Get your orders, results is paginated.', scopes: %w(history trade)
    params do
      optional :market, type: String, desc: ::APIv2::Entities::Market.documentation[:id]
      optional :state, type: Array(String), values: Order.state.values, desc: "Filter order by state, default to 'wait' (active orders)."
      optional :limit, type: Integer, default: 100, range: 1..1000, desc: "Limit the number of returned orders, default to 100."
      optional :page,  type: Integer, default: 1, desc: "Specify the page of paginated results."
      optional :order_by, type: String, values: %w(asc desc), default: 'asc', desc: "If set, returned orders will be sorted in specific order, default to 'asc'."
      # For filters
      optional :side, type: String, values: %w(sell buy), desc: "Filter order by order type, default to "
      optional :from, type: Date, desc: "Filter order by date"
      optional :to, type: Date, desc: "Filter order by date"
      optional :hide_cancel, type: Boolean, desc: "All Order without cancel state"

    end
    get "/order_history" do
      orders = current_user.orders
                   .order(order_param)
                   .page(params[:page])
                   .per(params[:limit])
      if params[:side].present?
        type = params[:side] == 'sell' ? 'OrderAsk' : 'OrderBid'
        orders = orders.where(type: type)
      end
      orders = orders.where('created_at BETWEEN ? AND ?', params[:from].to_date, params[:to].to_date) if params[:from].present? && params[:to].present?
      if params[:hide_cancel] == true
        orders = orders.with_state('done')
      else
        if params[:state].class == Array
          if params[:state].length == 1
            orders = orders.with_state(params[:state][0])
          elsif params[:state].length == 2
            orders = orders.with_state(params[:state][0], params[:state][1])
          elsif params[:state].length == 3
            orders = orders.with_state(params[:state][0], params[:state][1], params[:state][2])
          end
        end
      end
      orders = orders.with_currency(current_market) if current_market
      present orders, with: APIv2::Entities::Order
    end

  end
end
