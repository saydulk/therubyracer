module APIv2
  module Entities
    class Withdraw < Base
      expose :id
      expose(:currency) { |w| w.currency.upcase }

      expose (:blockchain_url) { |w| Currency.find_by_code(w.currency).address_blockchain_url(w.txid.to_s) }

      expose :amount
      expose :fee
      expose :txid
      expose :fund_uid, as: :address
      expose :state do |withdraw|
        case withdraw.aasm_state.to_sym
          when :canceled                            then :cancelled
          when :suspect                             then :suspected
          when :rejected, :accepted, :done, :failed then withdraw.aasm_state
          when :processing                          then :processing
          else :submitted
        end
      end
      expose :created_at, :updated_at, :done_at, format_with: :iso8601
    end
  end
end