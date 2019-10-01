json.asks @asks
json.bids @bids
json.trades @trades

if @member
  json.my_trades @trades_done.map(&:for_notify)
  json.my_orders *([@orders_wait] + Order::ATTRIBUTES)
  json.orders_history @orders_history.map(&:for_orders_history)
  json.all_history @all_history
end
