module APIv2
  module Helpers
    def authenticate!
      current_user or raise AuthorizationError
    end

    def redis
      @r ||= KlineDB.redis
    end

    def current_user
      # Keypair authentication provides member ID.
      if env.key?('api_v2.authentic_member_id')
        Member.find_by_id(env['api_v2.authentic_member_id'])

      # JWT authentication provides member email.
      elsif env.key?('api_v2.authentic_member_email')
        Member.find_by_email(env['api_v2.authentic_member_email'])
      end
    end

    def current_market
      @current_market ||= Market.find_by_id(params[:market])
    end

    def time_to
      params[:timestamp].present? ? Time.at(params[:timestamp]) : nil
    end

    def build_order(attrs)
      klass = attrs[:side] == 'sell' ? OrderAsk : OrderBid

      order = klass.new(
        source:        'APIv2',
        state:         ::Order::WAIT,
        member_id:     current_user.id,
        ask:           current_market.base_unit,
        bid:           current_market.quote_unit,
        currency:      current_market.id,
        ord_type:      attrs[:ord_type] || 'limit',
        price:         attrs[:price],
        volume:        attrs[:volume],
        origin_volume: attrs[:volume]
      )
    end

    def create_order(attrs)
      order = build_order attrs
      Ordering.new(order).submit
      order
    rescue
      Rails.logger.info "Failed to create order: #{$!}"
      Rails.logger.debug order.inspect
      Rails.logger.debug $!.backtrace.join("\n")
      raise CreateOrderError, $!
    end

    def create_orders(multi_attrs)
      orders = multi_attrs.map {|attrs| build_order attrs }
      Ordering.new(orders).submit
      orders
    rescue
      Rails.logger.info "Failed to create order: #{$!}"
      Rails.logger.debug $!.backtrace.join("\n")
      raise CreateOrderError, $!
    end

    def order_param
      params[:order_by].downcase == 'asc' ? 'id asc' : 'id desc'
    end

    def format_ticker(ticker)
      { at: ticker[:at],
        ticker: {
          buy: ticker[:buy],
          sell: ticker[:sell],
          low: ticker[:low],
          high: ticker[:high],
          last: ticker[:last],
          vol: ticker[:volume],
          open: ticker[:open],
          unit_price: ticker[:unit_price]
        }
      }
    end

    def get_k_json
      key = "peatio:#{params[:market]}:k:#{params[:period]}"

      if params[:timestamp]
        ts = JSON.parse(redis.lindex(key, 0)).first
        offset = (params[:timestamp] - ts) / 60 / params[:period]
        offset = 0 if offset < 0

        JSON.parse('[%s]' % redis.lrange(key, offset, offset + params[:limit] - 1).join(','))
      else
        length = redis.llen(key)
        offset = [length - params[:limit], 0].max
        JSON.parse('[%s]' % redis.lrange(key, offset, -1).join(','))
      end
    end

    def get_i18(entity, keyword)
      I18n.t("grape.entity.#{entity}.#{keyword}")
    end

    # OHLC(k line)

    def get_formatted_data(market, resolution, limit)
      params[:market] = market
      params[:period] = convert_resolution_into_period(resolution)
      params[:limit] = limit

      formatted_data = {t: [], o: [], h: [], c: [], l: [], v: [], s: 'no_data'}
      begin
        data = get_k_json
      rescue Exception => e
        Rails.logger.info "Error => #{e.backtrace}"
        data = []
      end
      unless data.empty?
        data.each do |record|
          formatted_data[:t].push record[0]
          formatted_data[:o].push record[1]
          formatted_data[:h].push record[2]
          formatted_data[:l].push record[3]
          formatted_data[:c].push record[4]
          formatted_data[:v].push record[5]
        end
        formatted_data[:s] = 'ok'
      end
      formatted_data
    end

    def convert_resolution_into_period(resolution)
      case resolution
      when '1D'
        1440
      when '7D'
        10080
      when '1M'
        43200
      else
        resolution
      end
    end

    def verify_devise!
      if token = BlacklistToken.find_by(email: params[:email], in_use: true)
        TokenMailer.signin_verify(token.email, params[:devise_id], params[:devise_type], token.id, '', true).deliver
        raise JWTAuthenticationError, params[:email]
      end
    end

  end
end
