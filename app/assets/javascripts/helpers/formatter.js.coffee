class Formatter
  round: (str, fixed) ->
    BigNumber(str).round(fixed, BigNumber.ROUND_HALF_UP).toF(fixed)

  fix: (type, str) ->
    str = '0' unless $.isNumeric(str)
    if type is 'ask'
      @.round(str, gon.market.ask.fixed)
    else if type is 'bid'
      @.round(str, gon.market.bid.fixed)

  fixAsk: (str) ->
    @.fix('ask', str)

  fixBid: (str) ->
    @.fix('bid', str)

  fixPriceGroup: (str) ->
    if gon.market.price_group_fixed
      str = '0' unless $.isNumeric(str)
      @.round(str, gon.market.price_group_fixed)
    else
      @fixBid(str)

  calculate_average: (origin_locked, locked, funds_received, kind) ->
    funds_used = origin_locked - locked
    if kind is 'ask'
      return fixAsk('0') if funds_used == 0 or not $.isNumeric(funds_used)
      avg = funds_received / funds_used
    else
      return fixBid('0') if funds_received == 0 or not $.isNumeric(funds_received)
      avg = funds_used / funds_received

    @.fix(kind, avg)

  getCookiebyName = (name) ->
    document.cookie.match(new RegExp(name + '=([^;]+)'))

  check_trend: (type) ->
    if type == 'up' or type == 'buy' or type == 'bid' or type == true
      true
    else if type == 'down' or type == "sell" or type = 'ask' or type == false
      false
    else
      throw "unknown trend smybol #{type}"

  market: (base, quote) ->
    "#{base.toUpperCase()}/#{quote.toUpperCase()}"

  market_url: (market, order_id) ->

    if order_id?
      "/markets/#{market}/orders/#{order_id}"
    else
      "/markets/#{market}"

  trade: (ask_or_bid) ->
    gon.i18n[ask_or_bid]

  short_trade: (type) ->
    if type == 'buy' or type == 'bid'
      gon.i18n['bid']
    else if type == "sell" or type = 'ask'
      gon.i18n['ask']
    else
      'n/a'

  trade_time: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("HH:mm")}#{m.format(":ss")}"

  fulltime: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("MM/DD HH:mm")}"

  fulltime_order: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("MM/DD HH:mm:ss")}"

  fulltime_with_year: ->
    moment().format('YYYY-MM-DD HH:mm:ss')

  mask_price: (price) ->
    price.replace(/\..*/, "<g>$&</g>")

  mask_fixed_price: (price) ->
    if (price == null) then  "market" else @mask_price @fixPriceGroup(price)

  ticker_fill: ['', '0', '00', '000', '0000', '00000', '000000', '0000000', '00000000']
  ticker_price: (price, fillTo=6) ->
    [left, right] = price.split('.')
    if fill = @ticker_fill[fillTo-right.length]
      "#{left}.<g>#{right}</g><span class='fill'>#{fill}</span>"
    else
      "#{left}.<g>#{right.slice(0,fillTo)}</g>"

  equivalent_dollar_price: (last_price, dollar_price, toFixed = 2) ->
    if dollar_price == undefined or last_price == undefined
      0.0
    else
      (parseFloat(last_price) * parseFloat(dollar_price)).toFixed(toFixed)


  price_change: (p1, p2) ->
    percent = if p1
                @round(100*(p2-p1)/p1, 2)
              else
                '0.00'
    "#{if p1 > p2 then '' else '+'}#{percent}"

  long_time: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("YYYY/MM/DD HH:mm")}"

  mask_fixed_volume: (volume) ->
    @.fixAsk(volume).replace(/\..*/, "<g>$&</g>")

  fix_ask: (volume) ->
    @.fixAsk volume

  fix_bid: (price) ->
    @.fixBid price

  amount: (amount, price,fixedTo=8) ->
    if price == null
      "-"
    else
      val = (new BigNumber(amount)).times(new BigNumber(price))
      val.toFixed(fixedTo)

  amount_update: (amount, price, fixedTo=6) ->
    val = (new BigNumber(amount)) * (new BigNumber(price))
    val.toFixed(fixedTo)

  total_amount_title: (amount, price) ->
    if price == null
      "-"
    else
      (Number(amount) * Number(price))


  ticker_color_class: (last, open) ->
    if last == open
      ""
    else if last < open
      "pink_txt"
    else if last > open
      "green_txt"

  fulled_amount: (origin_volume,volume) ->
    val = @round((new BigNumber(origin_volume)) - (new BigNumber(volume)), 6)

#    @.fixAsk(val).replace(/\..*/, "<g>$&</g>")

  trend: (type) ->
    if @.check_trend(type)
      "text-up"
    else
      "text-down"

  trend_icon: (type) ->
    if @.check_trend(type)
      "<i class='fa fa-caret-up text-up'></i>"
    else
      "<i class='fa fa-caret-down text-down'></i>"

  t: (key) ->
    gon.i18n[key]


  percentage_color: (price,volume) ->
   @round((100*(price-gon.ticker.last)/price) * volume, 2)


  market_set_capitalize: (market) ->
    gon.markets[market]['name']

  get_order_type: (price) ->
    if price == null
      "Market"
    else
      "Limit"

  order_status: (state) ->
    if state == "done"
      "Filled"
    else if state == "cancel"
      "Cancelled"
    else
      "Open"

  get_trade_state: (org_vol, vol) ->
    if parseFloat(vol) is 0.0
      'full'
    else if org_vol == vol
      'new'
    else
      'partial'

window.formatter = new Formatter()
