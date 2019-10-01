app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state('deposits', {
      url: '/deposits'
      views:{
        'deposit_data':{
          templateUrl: "/templates/funds/deposits.html"
        },
        'history_data':{
          templateUrl: "/templates/funds/deposit_history.html"
        }
      }

    })
    .state('deposits.currency', {
      url: "/:currency"
      templateUrl: "/templates/funds/deposit.html"
      controller: 'DepositsController'
      currentAction: 'deposit'
    })
    .state('withdraws', {
      url: '/withdraws'
      views:{
        'deposit_data':{
          templateUrl: "/templates/funds/withdraws.html"
        },
        'history_data':{
          templateUrl: "/templates/funds/_withdraw_coin_history.html"
        }
      }
    })
    .state('withdraws.currency', {
      url: "/:currency"
      templateUrl: "/templates/funds/withdraw.html"
      controller: 'WithdrawsController'
      currentAction: "withdraw"
    })