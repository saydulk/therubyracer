window.MarketTickerUI = flight.component ->
  @attributes
    askSelector: '.ask .price'
    bidSelector: '.bid .price'
    lastSelector: '.last .price'
    priceSelector: '.price'
    marketsTable: '.table.markets'

  @updatePrice = (selector, price, trend) ->
    selector.removeClass('text-up').removeClass('text-down').addClass(formatter.trend(trend))
    selector.html(formatter.fixBid(price))

  @refresh = (event, ticker) ->
    @updatePrice @select('askSelector'),  ticker.sell, ticker.sell_trend
    @updatePrice @select('bidSelector'),  ticker.buy,  ticker.buy_trend
    @updatePrice @select('lastSelector'), ticker.last, ticker.last_trend

  @after 'initialize', ->
    @on document, 'market::ticker', @refresh

    $.each $('.markets tr'), (index, val) ->
      active_tab = $('ul#markets_tab').find('li').find('a.active').attr("data-name")
      active_class =  'quote-'+active_tab
      if $(val).hasClass(active_class)  then $(val).show() else $(val).hide()

