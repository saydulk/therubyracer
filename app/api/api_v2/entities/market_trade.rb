module APIv2
  module Entities
    class MarketTrade < Base

      expose :id, as: :tid
      expose :price
      expose :volume, as: :amount
      expose :created_at, as: :date, format_with: :time_stamp
      expose :dollar_price do|trade, options|
        Rails.cache.read "peatio:#{trade.currency}:dollar_price"
      end

      expose :type do |trade, options|
        trade.trend == 'down' ? 'sell' : 'buy'
      end
    end
  end
end
