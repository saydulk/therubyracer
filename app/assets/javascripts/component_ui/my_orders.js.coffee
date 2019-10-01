@MyOrdersUI = flight.component ->
  flight.compose.mixin this, [ItemListMixin]


  @getTemplate = (order) -> $(JST["templates/order_active"](order))

  @orderHandler = (event, order) ->
    return unless order.market == gon.market.id

    switch order.state
      when 'wait'
        @addOrUpdateItem order
      when 'cancel'
        @removeItem order.id
      when 'done'
        @removeItem order.id


#  @cancelOrder = (event) ->
#    tr = $(event.target).parents('tr')
#    if tr.find('td').length != 1
#     if confirm(formatter.t('place_order')['confirm_cancel'])
#      $.ajax
#        url:     formatter.market_url gon.market.id, tr.data('id')
#        method:  'delete'
#        success: =>
#         setTimeout(window.location.reload.bind(window.location), 1000)

  $(document).ready ->
    $('body').on 'click', '.cancel_btn',(event) ->
      tr = $(event.target).parents('tr')
      if tr.find('td').length != 1
        if confirm(formatter.t('place_order')['confirm_cancel'])
          $.ajax
            url:     formatter.market_url gon.market.id, tr.data('id')
            method:  'delete'
            success: =>
              setTimeout(window.location.reload.bind(window.location), 1000)

  @after 'initialize', ->
    @on document, 'order::wait::populate', @populate
    @on document, 'order::wait order::cancel order::done', @orderHandler
#    @on @select('tbody'), 'click', @cancelOrder
    select_value = $('#open_orders_count').text() == "(0)"
    if select_value then $(".cancel_order").addClass('disable_dropdown') else $(".cancel_order").addClass('')