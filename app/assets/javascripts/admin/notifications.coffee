# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class Notifications
  constructor: ->
    @notifications = $("[data-behavior='notifications']")
    if @notifications.length > 0
      @setup()

  $ ->
    $('body').on 'click', "[data-behavior='mark-read']", ->
      notification_id = this.id
      tab = this.name
      unread(notification_id ,tab)
  setup: ->
#    $("[data-behavior='notifications-link']").on "click", @handleClick
    $.ajax(
      url: "/admin/notifications.json"
      dataType: "JSON"
      method: "GET"
      success: @handleSuccess
    )

  unread = (notification_id , tab) ->
    tab =  tab
    $.ajax(
      url: "/admin/notifications/"+notification_id+"/mark_as_read"
      dataType: "JSON"
      method: "POST"
      success: (data) ->
        select_tab(tab)
    )

  select_tab = (tab) ->
    rec = tab.split("_")
    entity_type = rec[0]
    exchange_name = rec[1]
    go_to_tab(entity_type,exchange_name)

  go_to_tab = (entity_type,exchange_name) ->
    all_data()
    window.location.href = '/admin/members/liquidity?entity_name=' + entity_type + '&exchange=' + exchange_name

  all_data = ->
    $.ajax(
      url: "/admin/notifications.json"
      dataType: "JSON"
      method: "GET"
      success: @handleSuccess
    )

  handleSuccess: (data) =>
    items = []
    unread_count = 0
    $.each data, (i, notification) ->
      item = ""
      item = item + " <li> <p> <b> " + notification['email'] + " </b> has low balance </p> <ul> <li>"
      if !notification.read_at
        unread_count += 1
        item = item + "<a href='#' data-behavior='mark-read' name=" + notification.entity_type + "_" + notification.exchange.toUpperCase() + " id = " + notification.notification_id + ">Mark as read</a></li></ul></li>"
      items.push item


    $("[data-behavior='unread-count']").text(unread_count)
    $("[data-behavior='notification-items']").html("")

    items.map (item) ->
      $("[data-behavior='notification-items']").append(item)
jQuery ->
  new Notifications