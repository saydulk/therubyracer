@HeaderUI = flight.component ->
  @attributes
    vol: 'span.vol'
    amount: 'span.amount'
    high: 'span.high'
    low: 'span.low'
    change: 'span.change'
    last: 'span.last'
    sound: 'input[name="sound-checkbox"]'

  @refresh = (event, ticker) ->
    change_color = formatter.ticker_color_class(ticker.last, ticker.open)
    @select('vol').text("#{ticker.volume} #{gon.market.base_unit.toUpperCase()}")
    @select('high').html("<span>#{formatter.ticker_price(ticker.high , 8)}</span>")
    @select('low').html("<span>#{formatter.ticker_price(ticker.low , 8)}</span>")
    @select('last').html("<span class='#{change_color}'>#{formatter.ticker_price(ticker.last, 8)}</span><span>$#{formatter.equivalent_dollar_price(ticker.last, ticker.unit_price)}</span>")

    p1 = parseFloat ticker.open
    p2 = parseFloat ticker.last
    trend = formatter.trend(p1 <= p2)
    @select('change').html("<span class='#{change_color}'>#{formatter.fulled_amount(ticker.last, ticker.open)}</span>&nbsp; &nbsp;<span class='#{change_color}'>#{formatter.price_change(p1, p2)}%</span>")

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh

    if Cookies.get('sound') == undefined
      Cookies.set('sound', true, 30)
    state = Cookies.get('sound') == 'true' ? true : false

    @select('sound').bootstrapSwitch
      labelText: gon.i18n.switch.sound
      state: state
      handleWidth: 40
      labelWidth: 40
      onSwitchChange: (event, state) ->
        Cookies.set('sound', state, 30)

    $('header .dropdown-menu').click (e) ->
      e.stopPropagation()
