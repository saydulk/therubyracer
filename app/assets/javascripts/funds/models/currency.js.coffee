class Currency extends PeatioModel.Model
  @configure 'Currency', 'key', 'code', 'coin', 'blockchain', 'quick_withdraw_min', 'quick_withdraw_max'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record)

  @minVal: (currency) ->
    Currency.findBy('code', currency)['quick_withdraw_min']

  @maxVal: (currency) ->
    Currency.findBy('code', currency)['quick_withdraw_max']

window.Currency = Currency
