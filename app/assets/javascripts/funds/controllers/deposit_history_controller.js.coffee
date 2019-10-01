app.controller 'DepositHistoryController', ($scope, $stateParams, $http, $rootScope) ->
  ctrl = @
  $scope.predicate = '-id'
  $scope.selected_txtid = ''

  @currency = $stateParams.currency || window.location.hash.split('/')[2]
  @account = Account.findBy('currency', @currency)
  @deposits = @account.deposits()
#  $scope.deposit_history = $scope.account.deposits()


  $scope.toogle_arrow = (tag_id) ->
#    $scope.arrow_down = !($scope.arrow_down)
    $scope.selected_txtid = tag_id

  @newRecord = (deposit) ->
    if deposit.aasm_state == "submitting" then true else false

  @noDeposit = ->
    @deposits.length == 0

  @refresh = ->
    @deposits = @account.deposits()
    $scope.$apply()

  @cancelDeposit = (deposit) ->
    deposit_channel = DepositChannel.findBy('currency', deposit.currency)
    $http.delete("/deposits/#{deposit_channel.resource_name}/#{deposit.id}")
      .error (responseText) ->
        $.publish 'flash', { message: responseText }

  @canCancel = (state) ->
    ['submitting'].indexOf(state) > -1

  do @event = ->
    Deposit.bind "create update destroy", ->
      ctrl.refresh()
