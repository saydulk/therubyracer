# require yarn_components/raven-js/dist/raven
#= require yarn_components/raven.min
#= require ./lib/sentry

#= require es5-shim.min
#= require es5-sham.min

#= require jquery
#= require jquery_ujs
#= require jquery.mousewheel
#= require jquery-timing.min
#= require jquery.nicescroll.min
#
#= require bootstrap

#= require charting_library/charting_library.min
#= require datafeeds/udf/dist/polyfills
#= require datafeeds/udf/dist/bundle

#= require bootstrap-switch.min
#
#= require moment
#= require bignumber
#= require underscore
#= require cookies.min
#= require flight.min
#= require pusher.min

#= require ./lib/sfx
#= require ./lib/notifier
#= require ./lib/pusher_connection

#= require highstock
#= require_tree ./highcharts/

#= require_tree ./helpers
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui
#= require_tree ./templates

#= require simplebar

#= require_self

$ ->
  window.notifier = new Notifier()

  BigNumber.config(ERRORS: false)

  HeaderUI.attachTo('header')
  AccountSummaryUI.attachTo('#account_summary')

  FloatUI.attachTo('.float')
  KeyBindUI.attachTo(document)
  AutoWindowUI.attachTo(window)

  PlaceOrderUI.attachTo('#bid_entry')
  PlaceOrderUI.attachTo('#ask_entry')
  PlaceOrderUI.attachTo('#market_bid_entry')
  PlaceOrderUI.attachTo('#market_ask_entry')
#  OrderBookUI.attachTo('#ask_order_book, #bid_order_book')
  OrderBookUI.attachTo('#market_order_book, #ask_order_book, #bid_order_book')

#  DepthUI.attachTo('#depths_wrapper')

  MyOrdersUI.attachTo('#my_orders')
  OrdersHistoryUI.attachTo('#orders')
  OrderHistoryToggleUI.attachTo('.open_order_inner, #orders')
  MarketTickerUI.attachTo('#ticker')
  MarketSwitchUI.attachTo('#market_list_wrapper')
  MarketTradesUI.attachTo('#market_trades_wrapper')
  FooterUI.attachTo('#footer_data')

  MarketData.attachTo(document)
  GlobalData.attachTo(document, {pusher: window.pusher})
  MemberData.attachTo(document, {pusher: window.pusher}) if gon.accounts

#  CandlestickUI.attachTo('#candlestick')
  SwitchUI.attachTo('#range_switch, #indicator_switch, #main_indicator_switch, #type_switch')

  $('.panel-body-content').niceScroll
    autohidemode: true
    cursorborder: "none"

  Number::formatMoney = (places, symbol, thousand, decimal) ->
    places = if !isNaN(places = Math.abs(places)) then places else 2
    symbol = if symbol != undefined then symbol else '$'
    thousand = thousand or ','
    decimal = decimal or '.'
    number = this
    negative = if number < 0 then '-' else ''
    i = parseInt(number = Math.abs(+number or 0).toFixed(places), 10) + ''
    j = if (j = i.length) > 3 then j % 3 else 0
    symbol + negative + (if j then i.substr(0, j) + thousand else '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + thousand) + (if places then decimal + Math.abs(number - i).toFixed(places).slice(2) else '')
