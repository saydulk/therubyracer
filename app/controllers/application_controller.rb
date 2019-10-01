class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # http_basic_authenticate_with :name => 'frodo', :password => 'thering' if Rails.env.eql?('development')

  helper_method :tabs
  helper_method :tab
  helper_method :current_user, :is_admin?, :current_market, :gon
  before_action :set_timezone, :set_gon, :session_manage
  after_action :allow_iframe
  after_action :set_csrf_cookie_for_ng
  # rescue_from CoinRPC::ConnectionRefusedError, with: :coin_rpc_connection_refused
  rescue_from CoinAPI::ConnectionRefusedError, with: :coin_rpc_connection_refused

  private

  def currency
    "#{params[:ask]}#{params[:bid]}".to_sym
  end

  def current_market
    @current_market ||= Market.find_by_id(params[:market]) || Market.find_by_id(cookies[:market_id]) || Market.first
  end

  def redirect_back_or_settings_page
    if cookies[:redirect_to].present?
      redirect_to cookies[:redirect_to]
      cookies[:redirect_to] = nil
    else
      flash[:notice] = t('.signed_up') if params.has_key? 'password_confirmation'
      #redirect_to settings_path
      redirect_to  market_path('ethbtc')
    end
  end

  def current_user
    # if is_already_logged_in?
      @current_user ||= Member.current = Member.enabled.where(id: session[:member_id]).first
      @current_user
    # else
    #     Activity.find(cookies[:activity_id]).update_columns(is_logged: false) if cookies[:activity_id].present?
    #   cookies[:activity_id] = nil
    #   @current_user = nil
    # end
  end

  def is_already_logged_in?
    browser_type = UserAgent.parse(request.env["HTTP_USER_AGENT"]).browser
    ip_address = request.env['REMOTE_ADDR']
    Activity.find_by(member_id: session[:member_id], is_logged: true, ip_address: ip_address, browser_type: browser_type)
  end

  def auth_member!
    unless current_user
      set_redirect_to
      redirect_to root_path, alert: t('activations.new.login_required')
    end
  end

  def auth_activated!
    redirect_to settings_path, alert: t('private.settings.index.auth-activated') unless current_user.activated?
  end

  def auth_verified!
    unless current_user&.id_document&.verified?
      redirect_to settings_path, alert: t('private.settings.index.auth-verified')
    end
  end

  def session_manage
    redirect_to settings_path if controller_name.eql?('welcome') && current_user
  end

  def auth_anybody!
    redirect_to root_path if current_user
  end

  def auth_admin!
    redirect_to main_app.root_path unless is_admin?
  end

  def is_admin?
    current_user&.admin?
  end

  def set_timezone
    Time.zone =  browser_timezone ||  ENV['TIMEZONE']
  end

  def browser_timezone
    @browser_timezone ||= begin
      ActiveSupport::TimeZone[-cookies[:tz].to_i.minutes]
    end if cookies[:tz].present?
  end

  def extract_locale
    parsed_locale = request.url.split('/').last
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale.to_sym : nil
  end

  def set_gon
    I18n.locale = extract_locale || cookies[:lang] || I18n.locale
    cookies[:lang] = I18n.locale
    gon.environment = Rails.env
    gon.local = I18n.locale
    gon.market = current_market.attributes
    gon.ticker = current_market.ticker
    gon.markets = Market.to_hash

    gon.pusher = {
      key:       ENV.fetch('PUSHER_KEY', nil),
      cluster:   ENV.fetch('PUSHER_CLUSTER', 'eu'),
      wsHost:    ENV.fetch('PUSHER_HOST', 'ws.pusherapp.com'),
      wsPort:    ENV.fetch('PUSHER_WS_PORT', 80).to_i,
      wssPort:   ENV.fetch('PUSHER_WSS_PORT', 443).to_i,
      encrypted: ENV.fetch('PUSHER_ENCRYPTED', true)
    }

    gon.clipboard = {
      :click => I18n.t('actions.clipboard.click'),
      :done => I18n.t('actions.clipboard.done')
    }

    gon.i18n = {
      invalid: I18n.t('activerecord.errors.models.identity.attributes.email.invalid_email'),
      brand: I18n.t('gon.brand'),
      ask: I18n.t('gon.ask'),
      bid: I18n.t('gon.bid'),
      cancel: I18n.t('actions.cancel'),
      latest_trade: I18n.t('private.markets.order_book.latest_trade'),
      switch: {
        notification: I18n.t('private.markets.settings.notification'),
        sound: I18n.t('private.markets.settings.sound')
      },
      notification: {
        title: I18n.t('gon.notification.title'),
        enabled: I18n.t('gon.notification.enabled'),
        new_trade: I18n.t('gon.notification.new_trade')
      },
      time: {
        minute: I18n.t('chart.minute'),
        hour: I18n.t('chart.hour'),
        day: I18n.t('chart.day'),
        week: I18n.t('chart.week'),
        month: I18n.t('chart.month'),
        year: I18n.t('chart.year')
      },
      chart: {
        price: I18n.t('chart.price'),
        volume: I18n.t('chart.volume'),
        open: I18n.t('chart.open'),
        high: I18n.t('chart.high'),
        low: I18n.t('chart.low'),
        close: I18n.t('chart.close'),
        candlestick: I18n.t('chart.candlestick'),
        line: I18n.t('chart.line'),
        zoom: I18n.t('chart.zoom'),
        depth: I18n.t('chart.depth'),
        depth_title: I18n.t('chart.depth_title')
      },
      place_order: {
        confirm_submit: I18n.t('private.markets.show.confirm'),
        confirm_cancel: I18n.t('private.markets.show.cancel_confirm'),
        price: I18n.t('private.markets.place_order.price'),
        volume: I18n.t('private.markets.place_order.amount'),
        sum: I18n.t('private.markets.place_order.total'),
        price_high: I18n.t('private.markets.place_order.price_high'),
        price_low: I18n.t('private.markets.place_order.price_low'),
        full_bid: I18n.t('private.markets.place_order.full_bid'),
        full_ask: I18n.t('private.markets.place_order.full_ask')
      },
      trade_state: {
        new: I18n.t('private.markets.trade_state.new'),
        partial: I18n.t('private.markets.trade_state.partial'),
        full: I18n.t('private.markets.trade_state.full')
      }
    }

    gon.currencies = Currency.all.inject({}) do |memo, currency|
      memo[currency.code] = {
        code: currency[:code],
        symbol: currency[:symbol],
        isCoin: currency[:coin]
      }
      memo
    end

    gon.fiat_currency = Currency.first.code
    gon.fiat_currencies = Currency.fiats.map(&:code)

    gon.tickers = {}
    gon.market_prices = {}
    Market.all.each do |market|
      gon.tickers[market.id] = market.unit_info.merge(Global[market.id].ticker).merge({coin_name: Currency.coin_name(market.base_unit)})
    end

    MarketPrice.all.each do |record|
      gon.market_prices[record.base_unit] = record.amount
    end

    set_btc_and_dollar_price if gon.market_prices.empty?

    if current_user
      gon.user = { sn: current_user.sn }
      gon.accounts = current_user.accounts.inject({}) do |memo, account|
        memo[account.currency] = {
          currency: account.currency,
          balance: account.balance,
          locked: account.locked
        } if account.currency_obj.try(:visible)
        memo
      end
      gon.id_document = {aasm_state: current_user.id_document.aasm_state}
    end
  end

  def coin_rpc_connection_refused
    render 'errors/connection'
  end

  def save_session_key(member_id, key)
    Rails.cache.write "peatio:sessions:#{member_id}:#{key}", 1, expire_after: ENV['SESSION_EXPIRE'].to_i.minutes
  end

  def clear_all_sessions(member_id)
    if redis = Rails.cache.instance_variable_get(:@data)
      redis.keys("peatio:sessions:#{member_id}:*").each {|k| Rails.cache.delete k.split(':').last }
    end

    Rails.cache.delete_matched "peatio:sessions:#{member_id}:*"
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options' if Rails.env.development?
  end


  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def tabs
    { open_order: ['header.open_order_history', open_order_history_path],
      order: ['header.order_history', order_history_path],
      trade: ['header.trade_history', trade_history_path]
    }
  end

  def tab
    {
      deposit:["Withdraw",account_history_path],
      withdraw:["Deposit",account_history_path]
    }
  end

  def set_btc_and_dollar_price
    all_currencies = Currency.all.map(&:code)
    btc_unit_price = Cryptocompare::Price.find(all_currencies.map(&:upcase), %w(BTC), flag: true)
    all_currencies.each do |code|
      market_price = MarketPrice.find_or_initialize_by(base_unit: code)
      code_name = code.eql?('zch') ? 'ZEC' :code.upcase
      market_price.amount = Cryptocompare::Price.find(code_name, 'USD', true).dig(code_name, "USD" )
      market_price.btc_unit = btc_unit_price.dig((code.eql?('zch') ? 'ZEC' :code.upcase), "BTC")
      market_price.save
      Market.where(quote_unit: code).map(&:id).each do |market|
        Rails.cache.write "peatio:#{market}:dollar_price", market_price.amount
      end
    end
  end
end
