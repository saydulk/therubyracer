@TickerUI = flight.component ->

  @attributes
    tickerUl: 'ul.tickers_block'

  @updateTicker = (select, ticker) ->
    trend = formatter.ticker_color_class ticker.last, ticker.open
    p1 = parseFloat ticker.open
    p2 = parseFloat ticker.last

    select.find("div.change")
      .html("<p class='#{trend}'>#{formatter.price_change(p1, p2)}%</p>")

    select.find("p.last")
      .html("<strong class='#{trend}'>#{formatter.ticker_price(ticker.last)}</strong>")

    select.find("span.val")
      .text("#{formatter.round(ticker.volume, 2)}")

  @refresh = (event, data) ->
    ul = @select('tickerUl')
    for ticker in data.tickers
      @updateTicker ul.find("li.#{ticker.market}"), ticker.data

  @after 'initialize', ->
    @on document, 'ready', @refresh
    @on document, 'market::tickers', @refresh



