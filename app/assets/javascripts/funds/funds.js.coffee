#= require clipboard
#= require_tree ./models
#= require_tree ./filters
#= require_self
#= require_tree ./config
#= require_tree ./services
#= require_tree ./directives
#= require_tree ./controllers
#= require ./router
#= require ./events
#= require jquery
#= require jquery_ujs
#= require bootstrap-datepicker
#= require chosen-jquery

$ ->
  window.pusher_subscriber = new PusherSubscriber()

Member.initData         [gon.user]
DepositChannel.initData  gon.deposit_channels
WithdrawChannel.initData gon.withdraw_channels

Deposit.initData         gon.deposits
Account.initData         gon.accounts
Currency.initData        gon.currencies
Withdraw.initData        gon.withdraws
Market.initData          gon.markets

window.app = app = angular.module 'funds', ["ui.router", "ngResource", "translateFilters", "textFilters", "precisionFilters", "fiatprecisionFilters","ngDialog", "angularUtils.directives.dirPagination" , "720kb.datepicker"]


