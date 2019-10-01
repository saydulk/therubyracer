# require yarn_components/raven-js/dist/raven
#= require yarn_components/raven.min
#= require ./lib/sentry

#= require jquery
#= require pusher.min

#= require ./lib/tiny-pubsub
#= require angular
#= require angular-resource
#= require ./lib/angular-ui-router
#= require ./lib/peatio_model
#= require ./lib/ajax

#= require ./lib/pusher_connection
#= require ./lib/pusher_subscriber

#= require bignumber
#= require bootstrap
#= require ngDialog/ngDialog
#= require qrcode

#= require_self
#= require ./funds/funds
#= require ./funds/events

#= require es5-shim.min
#= require es5-sham.min
#= require jquery_ujs

#= require moment
#= require underscore
#= require flight.min
#= require list

#= require_tree ./helpers
#= require_tree ./component_mixin
#= require_tree ./component_data
#= require_tree ./component_ui


$(document).on 'click', '[data-clipboard-text], [data-clipboard-target]', (e) ->
  $action = $(this)

  # clipboard.js is initialized so it already listens for clicks.
  return if $action.data('clipboard')

  # Skip click.
  e.preventDefault()
  e.stopPropagation()

  $action.data('clipboard', true)

  # Lazy initialize clipboard.js.
  new Clipboard($action[0])

  # Emulate click.
  $action.click()

setTimeout -> BigNumber.config(ERRORS: false)
