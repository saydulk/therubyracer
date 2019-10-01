app.controller 'WithdrawsController', ['$scope', '$stateParams', '$http', '$gon', 'fundSourceService', 'ngDialog',  '$rootScope', ($scope, $stateParams, $http, $gon, fundSourceService, ngDialog, $rootScope) ->

  _selectedFundSourceId = null
  _selectedFundSourceIdInList = (list) ->
    for fs in list
      return true if fs.id is _selectedFundSourceId
    return false

#  $("#title").html('Withdraws')
  $rootScope.controller_name = 'Withdraws'


  $("#withdraw_trans_sub").removeClass('hide')
  $scope.currency = currency = $stateParams.currency

  $scope.minval = Currency.minVal($scope.currency)
  #  For later usage
  $scope.maxval = Currency.maxVal($scope.currency)

  $scope.current_user = current_user = $gon.user
  $scope.name = current_user.name
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.balance = $scope.account.balance

  $scope.currencyTranslationLocals = currency: currency.toUpperCase()
  $scope.currencyType = if gon.fiat_currencies.indexOf($scope.currency) == 0 then 'fiat' else 'coin'

  $scope.withdraw_channel = WithdrawChannel.findBy('currency', $scope.currency)
  $scope.fiatCurrency = gon.fiat_currency
  $scope.fiatCurrencyTranslationLocals = currency: gon.fiat_currency
  $scope.trades = Market.findAllLike($scope.currency.toUpperCase())
  $scope.id_document = $gon.id_document

  $rootScope.account_history_withdraw = $scope.account
  $rootScope.withdraw_history = $scope.account.withdraws()

  $scope.should_disable = (amount, balance) ->
    # KYC and E-mail must be verified
    return true if  ($gon.current_user.activated == false) or ( not($gon.id_document.aasm_state == "verified"))

    return true if (_selectedFundSourceId == null)

    if (parseFloat(amount) > 0 && parseFloat(amount) <= parseFloat(balance) && parseFloat(amount) >= $scope.minval ) && ( parseFloat(amount) <= $scope.maxval )
      return false
    else
      return true

  $scope.no_enough_balance = (amount, balance) ->
    parseFloat(amount) > parseFloat(balance)


  $scope.exact_amount = (filled_amount) ->
    if parseFloat($scope.withdraw_channel.fee) < parseFloat(filled_amount) && parseFloat(filled_amount) >= $scope.minval
      return parseFloat(filled_amount) - parseFloat($scope.withdraw_channel.fee)
    else
      return 0.0

#  $scope.selected_fund_source_id = (newId) ->
  $scope.selected_fund_source = (newId) ->
    if angular.isDefined(newId)
      _selectedFundSourceId = newId
    else
      _selectedFundSourceId

  $scope.total_balance = (balance, locked) ->
    return parseFloat(balance) + parseFloat(locked)

  $scope.fund_sources = ->
    fund_sources = fundSourceService.filterBy currency:currency
    # reset selected fundSource after add new one or remove previous one
    if not _selectedFundSourceId or not _selectedFundSourceIdInList(fund_sources)
    # $scope.selected_fund_source_id fund_sources[0].id if fund_sources.length
      if fund_sources.length
        $scope.selected_fund_source fund_sources[0].id
      else
        $scope.selected_fund_source null
    fund_sources

  # set defaultFundSource as selected
  defaultFundSource = fundSourceService.defaultFundSource currency:currency
  if defaultFundSource
    _selectedFundSourceId = defaultFundSource.id
  else
    fund_sources = $scope.fund_sources()
    _selectedFundSourceId = fund_sources[0].id if fund_sources.length

  # set current default fundSource as selected
  $scope.$watch ->
    fundSourceService.defaultFundSource currency:currency
  , (defaultFundSource) ->

#    $scope.selected_fund_source_id defaultFundSource.id if defaultFundSource
    $scope.selected_fund_source defaultFundSource.id if defaultFundSource

  @withdraw = {}
  @createWithdraw = (currency) ->
    return false if (_selectedFundSourceId == null)
    $scope.member = $gon.current_user
    withdraw_channel = WithdrawChannel.findBy('currency', currency)
    account = withdraw_channel.account()
    data = { withdraw: { member_id: current_user.id, currency: currency, sum: @withdraw.sum, fund_source: _selectedFundSourceId ,payment_id: @withdraw.payment_id} }
    if ($scope.member.sms_auth == 'sms_disable' && $scope.member.otp_module == 'disable')
      $scope.withdrawdisable()
      return false

    $('.form-submit > input').attr('disabled', 'disabled')
    $("div#divLoading").addClass('show');

    $http.post("/withdraws/#{withdraw_channel.resource_name}", data)
      .success ->
        $scope.withdraw_success()
        location.reload()
      .error (responseText) ->
        $.publish 'flash', { message: responseText }
      .finally =>
        @withdraw = {}
        $('.form-submit > input').removeAttr('disabled')
        $.publish 'withdraw:form:submitted'
#        location.reload()

  @withdrawAll = ->
    @withdraw.sum = Number($scope.account.balance)

  $scope.openFundSourceManagerPanel = ->
#    if $scope.currency == $gon.fiat_currency
    if ($scope.currency == 'inr' || $scope.currency == 'usd')
      template = '/templates/fund_sources/bank.html'
      className = 'ngdialog-theme-default custom-width'
    else
      template = '/templates/fund_sources/coin.html'
      className = 'ngdialog-theme-default custom-width coin'

    ngDialog.open
      template:template
      controller: 'FundSourcesController'
      className: className
      data: {currency: $scope.currency}

  $scope.withdraw_success = ->
    template = '/templates/fund_sources/success_withdraw.html'
    className = 'ngdialog-theme-default custom-width coin manage_add'

    ngDialog.open
      template:template
      controller: 'FundSourcesController'
      className: className
      data: {currency: $scope.currency}

  $scope.withdrawdisable = ->
    last_change_val =  new Date($scope.member.last_change);
    last_hours =  last_change_val.setDate(last_change_val.getDate()+1)

    template = '/templates/fund_sources/withdraw_disable.html'
    className = 'ngdialog-theme-default custom-width coin manage_add'

    ngDialog.open
     template:template
     controller: 'FundSourcesController'
     className: className
     data: {currency: $scope.currency }


]
