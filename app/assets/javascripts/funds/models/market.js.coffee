class Market extends PeatioModel.Model
  @configure 'Market', 'id', 'name'

  @initData: (records) ->

    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Market.create(record)

  @findAllLike: (val) ->
    matching_markets = []
    for record in @records
      matching_markets.push(record) if record.name.split('/')[0] == val
    return matching_markets

window.Market = Market