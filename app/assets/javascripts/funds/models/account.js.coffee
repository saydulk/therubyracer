class Account extends PeatioModel.Model
  @configure 'Account', 'member_id', 'currency', 'balance', 'locked', 'created_at', 'updated_at', 'in', 'out', 'deposit_address', 'legacy_address','name_text','currency_icon_url','priority', 'payment_id'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Account.create(record)

  deposit_channels: ->
    DepositChannel.findAllBy 'currency', @currency

  withdraw_channels: ->
    WithdrawChannel.findAllBy 'currency', @currency

  deposit_channel: ->
    DepositChannel.findBy 'currency', @currency

  deposits: ->
    Deposit.findAllBy('currency', @currency)
#    _.sortBy(Deposit.findAllBy('account_id', @id), (d) -> d.id).reverse()

  withdraws: ->
    Withdraw.findAllBy('account_id', @id)
#    _.sortBy(Withdraw.findAllBy('account_id', @id), (d) -> d.id).reverse()



  topDeposits: ->
    @deposits().reverse().slice(0,3)

  topWithdraws: ->
    @withdraws().reverse().slice(0,3)

window.Account = Account
