class OrderExchange < ActiveRecord::Base

  serialize :visited_exchange, Array
end
