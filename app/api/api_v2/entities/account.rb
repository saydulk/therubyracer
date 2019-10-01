module APIv2
  module Entities
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

      expose :max_withdraw_limit do |account, options|
        currency_model(account.currency)&.quick_withdraw_max
      end

      expose :min_withdraw_limit do |account, options|
        currency_model(account.currency)&.quick_withdraw_min
      end

      private

      def currency_model code
        Currency.find_by_code(code)
      end
    end
  end
end
