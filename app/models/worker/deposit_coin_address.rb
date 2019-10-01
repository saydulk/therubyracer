module Worker
  class DepositCoinAddress
    def process(payload)
      payload.symbolize_keys!
      return if %w(usd).include?(payload[:currency])
      payment_address = PaymentAddress.find_by_id payload[:payment_address_id]
      return if payment_address.nil?
      account = payment_address&.account&.member_id.to_s
      return if payment_address.address.present?
      if payload[:currency] == "xrp"
        wallet = Wallet.active.deposit.find_by_currency_id(payment_address.currency)
        return unless wallet
        payment_address.update!(WalletService[wallet].create_address.slice(:address, :secret))
      else
        attrs = case payload[:currency]
                  when 'bch', 'bsv', 'trx'
                    extract_addresses(%i(legacy_address address secret), payload[:currency], account)
                  else
                    extract_addresses(%i(address secret), payload[:currency], account)
                end
        payment_address.update!(attrs)
      end
      pusher_event(payment_address) unless payment_address.address.blank?
    end

    private

    def pusher_event(payment_address)
      ::Pusher["private-#{payment_address.account.member.sn}"].trigger_async 'deposit_address',{
          type: 'create',
          attributes: payment_address.as_json
      }
    end

    def extract_addresses(arg, currency, account = nil)
      coin_api = CoinAPI[currency]
      hash_obj = account.nil? ?  coin_api.create_address! : coin_api.create_address!(account)
      hash_obj.slice(*arg)
    end
  end
end