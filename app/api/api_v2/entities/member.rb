module APIv2
  module Entities
    class Member < Base
      expose :sn
      expose :name
      expose :email
      expose :accounts, using: ::APIv2::Entities::Account

      expose :estimated_amount do |member , options|
        member.set_estimated_price[0].round(8)
      end

      expose :btc_dollar_price do |member, options|
        MarketPrice.find_by_base_unit('btc')&.amount
      end
    end
  end
end
