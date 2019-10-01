module APIv2
  module Entities
    module Mobile
      class Account < Base
        expose :currency
        expose :balance, format_with: :decimal
        expose :locked,  format_with: :decimal

        expose :currency_name do |account, options|
          Currency.find_by_code(account.currency)&.currency_name
        end

        expose :fee do |account, options|
          WithdrawChannel.find_by_currency(account.currency)&.fee
        end

        expose :estimated_amount do |account , options|
          options[:user].set_estimated_price(Array(account))[0].round(2)
        end

        expose :btc_dollar_price do |account , options|
          ::MarketPrice.find_by_base_unit('btc')&.amount
        end


        expose :trades do |account , options|
          trades = []
          ::Market.where(base_unit: account.currency).each do |market|
            trades << { name: market.name, open: Rails.cache.read("peatio:#{market.id}:ticker:open") || 0 , last: Rails.cache.read("peatio:#{market.id}:ticker")[:last] || 0, unit_price: ::MarketPrice.find_by(base_unit: market.quote_unit)&.amount   }
          end
          trades
        end

      end
    end
  end
end