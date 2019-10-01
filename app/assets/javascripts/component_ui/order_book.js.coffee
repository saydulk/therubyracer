@OrderBookUI = flight.component ->
  @attributes
    bookLimit: 30
    askBookSel: 'table.asks'
    bidBookSel: 'table.bids'
    seperatorSelector: 'table.seperator'
    fade_toggle_depth: '#fade_toggle_depth'
    decimal_drop_down: '#decimal_drop_down'


  @update = (event, data) ->
    @updateOrders(@select('bidBookSel'), _.first(data.bids, @.attr.bookLimit), 'bid')
    @updateOrders(@select('askBookSel'), _.first(data.asks, @.attr.bookLimit), 'ask')

  @refresh = (event, ticker) ->
    $('#dollar_price').html("$#{formatter.equivalent_dollar_price(ticker.last, ticker.unit_price)}")

    p1 = parseFloat ticker.open
    p2 = parseFloat ticker.last

    if (p1 == p2)
      $('#last_price').html("<span>#{formatter.ticker_price(ticker.last , 8)}</span>")
    else if p2 < p1
      $('#last_price').html("<span class='pink_txt'>#{formatter.ticker_price(ticker.last , 8)} <i class='fa fa-long-arrow-down'></i></span>")
    else
      $('#last_price').html("<span class='green_txt'>#{formatter.ticker_price(ticker.last , 8)} <i class='fa fa-long-arrow-up '></i></span>")


  @appendRow = (book, template, data) ->
    data.classes = 'new'
    book.append template(data)

  @insertRow = (book, row, template, data) ->
    data.classes = 'new'
    row.before template(data)

  @updateRow = (row, order, index, v1, v2) ->
    row.data('order', index)
    return if v1.equals(v2)

    if v2.greaterThan(v1)
      row.addClass('text-up')
    else
      row.addClass('text-down')

    row.data('volume', order[1])
    row.find('td.volume').html(formatter.mask_fixed_volume(order[1]))
    row.find('td.amount').html(formatter.amount_update(order[1], order[0]))


  @mergeUpdate = (bid_or_ask, book, orders, template) ->
    rows = book.find('tr')

    i = j = 0
    while(true)
      row = rows[i]
      order = orders[j]
      $row = $(row)

      if row && order
        p1 = new BigNumber($row.data('price'))
        v1 = new BigNumber($row.data('volume'))
        p2 = new BigNumber(order[0])
        v2 = new BigNumber(order[1])

        if (bid_or_ask == 'ask' && p2.lessThan(p1)) || (bid_or_ask == 'bid' && p2.greaterThan(p1))
          @insertRow(book, $row, template,
            price: order[0], volume: order[1], index: j)
          j += 1
        else if p1.equals(p2)
          @updateRow($row, order, j, v1, v2)
          i += 1
          j += 1
        else
          $row.addClass 'obsolete'
          i += 1
      else if row
        $row.addClass 'obsolete'
        i += 1
      else if order
        @appendRow(book, template,
          price: order[0], volume: order[1], index: j)
        j += 1
      else
        break

  @clearMarkers = (book) ->
    book.find('tr.new').removeClass('new')
    book.find('tr.text-up').removeClass('text-up')
    book.find('tr.text-down').removeClass('text-down')

    obsolete = book.find('tr.obsolete')
    obsolete_divs = book.find('tr.obsolete a')
    obsolete_divs.slideUp 'slow', ->
      obsolete.remove()

  @updateOrders = (table, orders, bid_or_ask) ->
    book = @select("#{bid_or_ask}BookSel")

    @mergeUpdate bid_or_ask, book, orders, JST["templates/order_book_#{bid_or_ask}"]

    book.find("tr.new a").slideDown('slow')

    setTimeout =>
      @clearMarkers(@select("#{bid_or_ask}BookSel"))
    , 900

  @computeDeep = (event, orders) ->
    index      = Number $(event.currentTarget).data('order')
    orders     = _.take(orders, index + 1)

    volume_fun = (memo, num) -> memo.plus(BigNumber(num[1]))
    volume     = _.reduce(orders, volume_fun, BigNumber(0))
    price      = BigNumber(_.last(orders)[0])
    origVolume = _.last(orders)[1]

    {price: price, volume: volume, origVolume: origVolume}

  @placeOrder = (target, data) ->
      @trigger target, 'place_order::input::price', data

  @after 'initialize', ->
    @on document, 'market::order_book::update', @update
    @on document, 'market::ticker', @refresh


    @on @select('fade_toggle_depth'), 'click', =>
      @trigger 'market::depth::fade_toggle'

    @on @select('decimal_drop_down'), 'change', =>
      selected_decimals = parseInt($('#decimal_drop_down').val())
      $('table.asks tr').each ->
        reset_table($(this),selected_decimals )
      $('table.bids tr').each ->
        reset_table($(this),selected_decimals)

    reset_table =(current_tr, selected_decimals) ->
      actual_price = current_tr.attr("data-price")
      price_round =  formatter.round(actual_price, selected_decimals)
      price_split =  price_round.split('.')
      current_tr.find('td:first').html('<a class="ask_val">'+price_split[0]+'<g>.'+price_split[1]+' </g></a>')
      volume = current_tr.attr("data-volume")
      current_tr.find("td:eq(2)").find('.ask_val').text(formatter.amount(volume, price_round, selected_decimals))


    $('.asks, .bids').on 'click', 'tr', (e) =>
      price = $(e.target).closest('tr').data('price')
      @placeOrder $('#bid_entry'), {price: BigNumber(price)}
      @placeOrder $('#ask_entry'), {price: BigNumber(price)}
#      i = $(e.target).closest('tr').data('order')
#      @placeOrder $('#bid_entry'), _.extend(@computeDeep(e, gon.asks), type: 'ask')
#      @placeOrder $('#ask_entry'), {price: BigNumber(gon.asks[i][0]), volume: BigNumber(gon.asks[i][1])}

#    $('.bids').on 'click', 'tr', (e) =>
#      i = $(e.target).closest('tr').data('order')
#      @placeOrder $('#ask_entry'), _.extend(@computeDeep(e, gon.bids), type: 'bid')
#      @placeOrder $('#bid_entry'), {price: BigNumber(gon.bids[i][0]), volume: BigNumber(gon.bids[i][1])}

    $('.book_layout').on 'click',  (e) =>

      $(event.target).parent().siblings('.active').removeClass('active')
      $(event.target).parent().addClass('active')
      image_index = e.target.name
      $('.market_ask').addClass('hide')
      $('.market_bid').addClass('hide')
      if image_index == "0"
        $('.market_ask').removeClass('hide')
        $('.market_bid').removeClass('hide')
      else if image_index == "1"
        $('.market_bid').removeClass('hide')
      else if image_index == "2"
        $('.market_ask').removeClass('hide')
