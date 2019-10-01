#= require jquery
#= require jquery.min
#= require jquery_ujs

#= require js/bootstrap.min.js
#= require js/owl.carousel.min
#= require js/easyResponsiveTabs.js

#= require cookies.min
#= require flight.min
#= require pusher.min

#= require ./lib/sfx
#= require ./lib/notifier
#= require ./lib/pusher_connection

#= require_tree ./component_ui/wedget_ui

$ ->

  window.notifier = new Notifier()
  BigNumber.config(ERRORS: false)

  TickerUI.attachTo('#home_tickers')
  HomeMarketSwitchUI.attachTo('#home_market_list_wrapper')
  FooterUI.attachTo('#footer_data')


