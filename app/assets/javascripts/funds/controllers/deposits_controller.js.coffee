app.controller 'DepositsController', ['$scope','$rootScope', '$stateParams', '$http', '$filter', '$gon', 'ngDialog', ($scope, $rootScope,  $stateParams, $http, $filter, $gon, ngDialog) ->
  @deposit = {}
  $scope.currency = $stateParams.currency
  $scope.current_user = current_user = $gon.user
  $scope.minval = Currency.minVal($scope.currency)
  #  For later usage
  $scope.maxval = Currency.maxVal($scope.currency)
  $scope.name = current_user.name
  $scope.bank_details_html = $gon.bank_details_html
  $scope.fund_sources = $gon.fund_sources
  $scope.account = Account.findBy('currency', $scope.currency)
  $scope.deposit_channel = DepositChannel.findBy('currency', $scope.currency)

  $scope.currencyTranslationLocals = currency: $stateParams.currency.toUpperCase()
  $rootScope.currencyType = if gon.fiat_currencies.indexOf($scope.currency) == 0 then 'fiat' else 'coin'


  $scope.fiatCurrency = gon.fiat_currency
  $scope.fiatCurrencyTranslationLocals = currency: gon.fiat_currency
  $scope.trades = Market.findAllLike($scope.currency.toUpperCase())
  $scope.checkboxterms = {
    value1 : false
  };
  $scope.proceed_btn = true
  $scope.proceed_accepted = false
  $scope.xrp_deposit_tag =''

  $rootScope.account_history = $scope.account
  $rootScope.deposit_history = $scope.account.deposits()

  $("#deposit_trans_sub").removeClass('hide')
#  $("#title").html('Deposit')
  $rootScope.controller_name = 'Deposit'

  @createDeposit = (currency) ->
    depositCtrl = @
    deposit_channel = DepositChannel.findBy('currency', currency)
    account = deposit_channel.account()

    data = { account_id: account.id, member_id: current_user.id, currency: currency, amount: @deposit.amount, fund_source: @deposit.fund_source }

    $.publish 'flash', {message: "Successfully Deposit" }

    $('.form-submit > input').attr('disabled', 'disabled')
#    location.reload();

    $http.post("/deposits/#{deposit_channel.resource_name}", { deposit: data})
      .error (responseText) ->
        $.publish 'flash', {message: responseText }
      .finally ->
        depositCtrl.deposit = {}
        $('.form-submit > input').removeAttr('disabled')

  $scope.total_balance = (balance, locked) ->
    return parseFloat(balance) + parseFloat(locked)

  $scope.openQRCodePanel = ->
    ngDialog.open
      template: '/templates/funds/_qrcode.html'
      controller: 'DepositsController'
      className: 'ngdialog-theme-default'
      data: {account: $scope.account}

  $scope.opentagQRCodePanel = ->
    if $scope.account.deposit_address
      $scope.tag_address = $scope.account.deposit_address.split("=")
      $scope.xrp_deposit_tag = $scope.tag_address[1]
    ngDialog.open
      template: '/templates/funds/_tag_qrcode.html'
      controller: 'DepositsController'
      className: 'ngdialog-theme-default'
      data: {account: $scope.xrp_deposit_tag}


  $scope.openFundSourceManagerPanel = ->
    ngDialog.open
      template: '/templates/fund_sources/bank.html'
      controller: 'FundSourcesController'
      className: 'ngdialog-theme-default custom-width'
      data: {currency: $scope.currency}

  $scope.genAddress = (resource_name) ->
    ngDialog.openConfirm
      template: '/templates/shared/confirm_dialog.html'
      data: {content: $filter('t')('funds.deposit_coin.confirm_gen_new_address')}
    .then ->
      $("a#new_address").html('...')
      $("a#new_address").attr('disabled', 'disabled')

#      $http.post("/deposits/#{resource_name}/gen_address",authenticity_token: $('meta[name="csrf-token"]').attr('content'))
      $http.post("/deposits/#{resource_name}/gen_address")
        .error (responseText) ->
          $.publish 'flash', {message: responseText }
        .finally ->
          $("a#new_address").html(I18n.t("funds.deposit_coin.new_address"))
          $("a#new_address").attr('disabled', 'disabled')


  $scope.deposit_fiat = (currency) ->
    formData = new FormData
    $input = $('#file_upload')
    formData.append 'deposit[avatar]', $input[0].files[0]
    formData.append 'deposit[amount]', $scope.amount_deposit
    formData.append 'deposit[done_at]',  $scope.transaction_date
    formData.append 'deposit[fund_uid]',  $scope.transaction_id
    formData.append 'deposit[currency]',  currency
    $.ajax
      url: '/deposits/fiats'
      data: formData
      cache: false
      contentType: false
      processData: false
      type: 'POST'
      success: (data) ->
        location.reload()
      error: (responseText) ->
        $.publish 'flash', {message: 'Upload not done successfully' }

  $scope.valid_number = () ->
    if $scope.amount_deposit
      $scope.amount_deposit = $scope.amount_deposit.replace(/[^0-9\.]/g, '')

  $scope.generate_qrcode = (data) ->
    code = data
    $("#qrcode").attr('data-text', code)
    $("#qrcode").attr('title', code)
    $('.qrcode-container').each (index, el) ->
      $el = $(el)
      $("#qrcode img").remove()
      $("#qrcode canvas").remove()

      new QRCode el,
        text:   $("#qrcode").attr('data-text')
        width:  $el.data('width')
        height: $el.data('height')



  $scope.$watch (-> $scope.account.deposit_address), ->
    setTimeout(->
      if $scope.account.currency == 'xrp'
        address = if  $('#qrcode1').is(":visible") then $scope.account.deposit_address.split("=")[1] else  $scope.account.deposit_address.split("?")[0]
      else
        address = if ($scope.account.currency == 'bch') then $scope.account.legacy_address else $scope.account.deposit_address
      $scope.generate_qrcode(address)
    , 1000)

  $scope.xrp_terms = (checkStatus) ->
    if $scope.checkboxterms.value1
      $scope.proceed_btn = false
    else
      $scope.proceed_btn = true
      $scope.proceed_accepted = false

  $scope.proceed_xrp= () ->
    $scope.proceed_accepted = true
    if $scope.proceed_accepted && $scope.account.deposit_address
      $scope.split_xrp = $scope.account.deposit_address.split("?")
      $scope.xrp_address = $scope.split_xrp[0]
      $scope.xrp_deposit_tag = $scope.split_xrp[1].split("=")[1]

]
