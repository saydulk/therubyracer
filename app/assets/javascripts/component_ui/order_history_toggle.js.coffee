@OrderHistoryToggleUI = flight.component ->
  @attributes
    innerSelector: '.open_order_inner'
    toggleCheckbox: '#hide_other_pair'
    checkbox_order: '#other_checkbox'

  @toggleMarketRows = (event) ->

    if @select('checkbox_order').is ':checked'
      $('#orders').find('table tr').each (index, item) ->
        if index > 0
          if $(item).hasClass(gon.market.id)
            $(item).show()
          else
            $(item).hide()
        $('#history_orders_count').text $('#orders').find('table tr:visible').length - 1
        return
    else
      $('#orders').find('table tr').show()
      $('#history_orders_count').text gon.all_history

    return

  @after 'initialize', ->
    @on @select('toggleCheckbox'), 'click', @toggleMarketRows

