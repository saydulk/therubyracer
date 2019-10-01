# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Rippled < Base

    def create_address(options = {})
      client.create_address!(options.merge(
        address: "#{wallet.address}?dt=#{generate_destination_tag}",
        secret: wallet.settings['secret']
      ))
    end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      pa = deposit.account.payment_address

      client.create_withdrawal!(
        { address: pa.address, secret: pa.secret },
        { address: destination_address },
        deposit.amount,
        options
      )
    end

    def build_withdrawal!(withdraw, options = {})
      receipent_address = withdraw['fund_uid'] ? withdraw.fund_uid : withdraw.receipent_address
      client.create_withdrawal!(
        { address: wallet.address, secret: wallet.secret },
        { address: receipent_address },
        withdraw.amount,
        options
      )
    end

    def load_balance(address, currency)
      client.load_balance!(address, currency)
    end




    private

    def generate_destination_tag
      begin
        # Reserve destination 1 for system purpose
        tag = SecureRandom.random_number(10**9) + 2
      end while PaymentAddress.where(currency: :xrp)
                              .where('address LIKE ?', "%dt=#{tag}")
                              .any?
      tag
    end
  end
end
