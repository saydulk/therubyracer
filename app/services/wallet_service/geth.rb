# encoding: UTF-8
# frozen_string_literal: true

module WalletService
  class Geth < Base

    DEFAULT_ETH_FEE = { gas_limit: 300_000, gas_price: 10_000_000_000 }.freeze

    #DEFAULT_ERC20_FEE_VALUE =  100_000 * DEFAULT_ETH_FEE[:gas_price]
    DEFAULT_ERC20_FEE_VALUE = {gas_limit: 300_000, gas_price: 10_000_000_000}.freeze

    # def create_address(options = {})
    #   client.create_address!(options)
    # end

    def collect_deposit!(deposit, options={})
      destination_address = destination_wallet(deposit).address
      if deposit.currency.eth?
        collect_eth_deposit!(deposit, destination_address, options)
      else
        collect_erc20_deposit!(deposit, destination_address, options)
      end
    end

    def build_withdrawal!(withdraw, options = {})
      Rails.logger.info"==build_withdrawal!====#{withdraw.inspect}===="
      currency = withdraw['currency'] ? withdraw.currency : withdraw.currency_id
      if currency == "eth"
        build_eth_withdrawal!(withdraw)
      else
        build_erc20_withdrawal!(withdraw, options)
      end
    end

    def deposit_collection_fees(deposit, value=DEFAULT_ERC20_FEE_VALUE, options={})
      fees_wallet = erc20_fee_wallet
      destination_address = deposit.account.payment_address.address
      options = DEFAULT_ETH_FEE.merge options
      # calculate the required eth amount to send the ERC20 tokens
      eth_estimate_gas = client.eth_fees_for_erc20(deposit.amount)
      eth_estimate_gas += (eth_estimate_gas / 20)
      options[:gas_limit] = eth_estimate_gas if (eth_estimate_gas > DEFAULT_ETH_FEE[:gas_limit])
      value = value.class.eql?(Hash) ? (value[:gas_limit] * value[:gas_price]) : value
      client.create_eth_withdrawal!(
          { address: fees_wallet.address, secret: fees_wallet.secret },
          { address: destination_address },
          value,
          options
      )
    end

    # def transfer_withdrawal!(transfer,options = {})
    #   Rails.logger.info"===========transfer======#{transfer}======="
    #   client.create_eth_withdrawal!(
    #       { address: wallet.address, secret: wallet.secret },
    #       { address: transfer.receipent_address },
    #       transfer.amount_to_base_unit!
    #   )
    # end


    def transaction_status!(txid)
      client.get_txn_receipt(txid)
    end

    def load_balance(address, currency)
      client.load_balance!(address, currency)
    end

    private

    def erc20_fee_wallet
      # fee wallet use same as collection wallet of eth
      Wallet
          .active
          .withdraw
          .find_by(currency_id: :eth, kind: :hot)
    end

    def collect_eth_deposit!(deposit, destination_address, options={})
      # Default values for Ethereum tx fees.
      options = DEFAULT_ETH_FEE.merge options

      # We can't collect all funds we need to subtract gas fees.
      amount_deposit = deposit.amount
      base_factor= 1_000_000_000_000_000_000
      x = amount_deposit.to_d * base_factor
      unless (x % 1).zero?
        raise StandardError::Error, "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: " +
            "#{amount_deposit.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i

      amount = x - options[:gas_limit] * options[:gas_price]
      pa = deposit.account.payment_address
      client.create_eth_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: destination_address },
          amount,
          options
      )
    end

    def collect_erc20_deposit!(deposit, destination_address, options={})
      pa = deposit.account.payment_address
      currency= deposit.currency
      options = DEFAULT_ERC20_FEE_VALUE.merge(options)
      erc20_contract_address= Currency.find_by_code(currency).contract_address
      client.create_erc20_withdrawal!(
          { address: pa.address, secret: pa.secret },
          { address: destination_address },
          deposit.amount_to_base_unit!,
          options.merge(contract_address: erc20_contract_address )
      )

    end

    def build_eth_withdrawal!(withdraw)
      receipent_address = withdraw['fund_uid'] ? withdraw.fund_uid : withdraw.receipent_address
      client.create_eth_withdrawal!(
          { address: wallet.address, secret: wallet.secret },
          { address: receipent_address},
          withdraw.amount_to_base_unit!
      )
    end

    def build_erc20_withdrawal!(withdraw, options={})
      Rails.logger.info"============trasfer==erc20====#{withdraw.inspect}"
      receipent_address = withdraw['fund_uid'] ? withdraw.fund_uid : withdraw.receipent_address
      currency = withdraw['currency'] ? withdraw.currency : withdraw.currency_id
      erc20_contract_address = Currency.find_by_code(currency).contract_address
      options = DEFAULT_ERC20_FEE_VALUE.merge options
      # calculate the required eth amount to send the ERC20 tokens
      eth_estimate_gas = client.eth_fees_for_erc20(withdraw.amount)
      eth_estimate_gas += (eth_estimate_gas / 20)
      options[:gas_limit] = eth_estimate_gas if (eth_estimate_gas > DEFAULT_ERC20_FEE_VALUE[:gas_limit])
      options[:contract_address] = erc20_contract_address
      client.create_erc20_withdrawal!(
          {address: wallet.address, secret: wallet.secret},
          {address: receipent_address},
          withdraw.amount_to_base_unit!,
          options
      )
    end
  end
end
