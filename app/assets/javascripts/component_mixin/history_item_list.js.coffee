@HistoryItemListMixin = ->
  @attributes
    tbody: 'table > tbody'
    empty: '.empty-row'

  @checkEmpty = (event, data) ->
    if @select('tbody').find('tr.order').length is 0
      @select('empty').parent().parent().fadeIn()
    else
      @select('empty').parent().parent().fadeOut()

  @addOrUpdateItem = (item) ->
    template = @getTemplate(item)
    existsItem = @select('tbody').find("tr[data-id=#{item.id}][data-kind=#{item.kind}]")

    if existsItem.length
      existsItem.html template.html()
    else
      console.log "item ==============   "+item
      template.prependTo(@select('tbody')).show('slow')

    @checkEmpty()

  @populate = (event, data) ->
    if not _.isEmpty(data.orders_history)
      @addOrUpdateItem item for item in data.orders_history
      $('#history_orders_count').html(data.orders_history.length)

    @checkEmpty()

