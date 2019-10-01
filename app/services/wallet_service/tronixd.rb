# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Tronixd < Base

    # def create_address(options = {})
    #   puts"=========options==#{options.inspect}==========="
    #   @client.create_address!(options)
    # end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      pa = deposit.account.payment_address

      # this will automatically deduct fee from amount
      options = options.merge( subtract_fee: true )

      client.create_withdrawal!(
          { address: pa.address },
          { address: destination_address },
          deposit.amount.to_i,
          options
      )
    end

    def build_withdrawal!(withdraw, options = {})
      client.create_withdrawal!(
          { address: wallet.address },
          { address: withdraw.fund_uid },
          withdraw.amount,
          options
      )
    end

    def transfer_withdrawal!(transfer,options = {})
      client.create_withdrawal!(
          { address: wallet.address, secret: wallet.secret },
          { address: transfer.receipent_address },
          transfer.amount,
          options
      )
    end

    def load_balance(address, currency)
      client.load_balance!(address, currency)
    end

  end
end
