module APIv2
  module Entities
    class Deposit < Base
      expose :id, documentation: "Unique deposit id."
      expose :currency
      expose :amount, format_with: :decimal
      expose :fee
      expose :fund_uid, as: :address
      expose :txid
      expose :created_at, format_with: :iso8601
      expose :confirmations
      expose :done_at, format_with: :iso8601
      expose :aasm_state, as: :state
      expose :currency_name
      expose (:blockchain_url) { |w| Currency.find_by_code(w.currency).address_blockchain_url(w.txid.to_s) }

      private

      def currency_name
        Currency.find_by_code(@object.currency).currency_name
      end
    end
  end
end
