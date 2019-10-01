app.controller 'WithdrawHistoryController', ($scope, $stateParams, $http) ->
  ctrl = @
  $scope.predicate = '-id'
  $scope.selected_txtid = ''

  @currency = $stateParams.currency || window.location.hash.split('/')[2]
  @account = Account.findBy('currency', @currency)
#  @withdraws = @account.withdraws().slice(0, 3)

  @withdraws = @account.withdraws()

  $scope.toogle_arrow = (tag_id) ->
#    $scope.arrow_down = !($scope.arrow_down)
    $scope.selected_txtid = tag_id

  @newRecord = (withdraw) ->
    if withdraw.aasm_state ==  "submitting" then true else false

  @noWithdraw = ->
    @withdraws.length == 0

  @refresh = ->
    ctrl.withdraws = ctrl.account.withdraws()
    $scope.$apply()

  @canCancel = (state) ->
    ['submitting', 'submitted', 'accepted'].indexOf(state) > -1

  @cancelWithdraw = (withdraw) ->
    withdraw_channel = WithdrawChannel.findBy('currency', withdraw.currency)
    $http.delete("/withdraws/#{withdraw_channel.resource_name}/#{withdraw.id}")
      .error (responseText) ->
        $.publish 'flash', { message: responseText }

  do @event = ->
    Withdraw.bind "create update destroy", ->
      ctrl.refresh()
