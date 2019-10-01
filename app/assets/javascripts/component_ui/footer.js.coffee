@FooterUI = flight.component ->

  @attributes
    btcItem: 'span.btc'
    ethItem: 'span.eth'
    usdtItem: 'span.usdt'


  @refresh = (event, data) ->
    btc_vol = eth_vol = usdt_vol = 0.0

    for ticker in data.tickers
      item = ticker.data

      if item.quote_unit == "btc"
        btc_vol = btc_vol + parseFloat(item.volume)

      else if item.quote_unit == "eth"
        eth_vol = eth_vol + parseFloat(item.volume)

      else if item.quote_unit == "usdt"
        usdt_vol = usdt_vol + parseFloat(item.volume)

    @select('btcItem').text(formatter.round(btc_vol, 3))
    @select('ethItem').text(formatter.round(eth_vol, 3))
    @select('usdtItem').text(formatter.round(usdt_vol, 3))

  @setTime =  ->
    $('span.date_time').text(formatter.fulltime_with_year())


  @after 'initialize', ->
    @on document, 'ready', @refresh
    @on document, 'market::tickers', @refresh

    setInterval @setTime, 1000



