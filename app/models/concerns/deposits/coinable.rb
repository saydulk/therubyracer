module Deposits
  module Coinable
    extend ActiveSupport::Concern

    included do
      validates_presence_of :payment_transaction_id
      validates_uniqueness_of :payment_transaction_id
      belongs_to :payment_transaction
    end

    def channel
      @channel ||= DepositChannel.find_by_key(self.class.name.demodulize.underscore)
    end

    def min_confirm?(confirmations)
      update_confirmations(confirmations)
      confirmations >= channel.min_confirm && confirmations < channel.max_confirm
    end

    def max_confirm?(confirmations)
      update_confirmations(confirmations)
      confirmations >= channel.max_confirm
    end

    def update_confirmations(confirmations)
      if !self.new_record? && self.confirmations.to_s != confirmations.to_s
        self.update!(confirmations: confirmations.to_s)
      end
    end

    def blockchain_url
      currency_obj.blockchain_url(txid) if currency_obj.present?
    end

    def as_json(options = {})
      super(options).merge({
        txid: txid.blank? ? "" : txid[0..29],
        txid_tip: txid,
        confirmations: payment_transaction.nil? ? 0 : payment_transaction.confirmations,
        blockchain_url: blockchain_url
      })
    end

    def amount_to_base_unit!
      currency = Currency.find_by_code(self.currency)
      x = amount.to_d * currency.base_factor
      unless (x % 1).zero?
        raise CoinAPI::Error, "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: "  "#{amount.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i
    end
  end
end
