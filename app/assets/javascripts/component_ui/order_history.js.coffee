@OrdersHistoryUI = flight.component ->
  flight.compose.mixin this, [HistoryItemListMixin]


  @getTemplate = (order) -> $(JST["templates/history_order_active"](order))

  @orderHandler = (event, order) ->
    records_no =  if $('#history_orders_count').text() then parseInt($('#history_orders_count').text()) else  0
    $('#history_orders_count').html( records_no + 1 )
    return unless order.market == gon.market.id
    @addOrUpdateItem order


  @after 'initialize', ->
    @on document, 'order::history::populate', @populate
    @on document, 'order::cancel order::done', @orderHandler
