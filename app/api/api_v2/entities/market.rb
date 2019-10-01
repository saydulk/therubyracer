module APIv2
  module Entities
    class Market < Base
      expose :id, documentation: "Unique market id. It's always in the form of xxxyyy, where xxx is the base currency code, yyy is the quote currency code, e.g. 'btcinr'. All available markets can be found at /api/v2/markets."

      expose :name

      expose :ask_precision do |market|
        market.ask['fixed']
      end

      expose :bid_precision do |market|
        market.bid['fixed']
      end

    end
  end
end
