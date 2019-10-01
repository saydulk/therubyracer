# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns API client for given gateway options hash.
    #
    # @param wallet [String, Symbol]
    #   The wallet object.
    # @return [BaseAPI]
    def [](wallet)
      "WalletClient::#{wallet.gateway.capitalize}"
        .constantize
        .new(wallet)
    end
  end

  class Base
    extend Memoist

    #
    # Returns the blockchain.
    #
    # @return [gateway]
    attr_reader :wallet

    def initialize(wallet)
      @wallet = wallet
    end

    def normalize_address(address)
      puts"========normalize_address======#{address}======"
      # wallet.blockchain_api&.case_sensitive? ? address : address.try(:downcase)
      case_sensitive? ? address : address.try(:downcase)
    end

    def normalize_txid(txid)
      puts"=========normalize_txid====#{txid}==============="
      # wallet.blockchain_api&.case_sensitive? ? txid : txid.try(:downcase)
      case_sensitive? ? txid : txid.try(:downcase)
    end

    # IMPORTANT: Be sure to set the correct value!
    def case_sensitive?
      true
    end


    def convert_from_base_unit(value, currency_code)
      currency = Currency.find_by_code(currency_code)
      value.to_d / currency.base_factor
    end

    def convert_to_base_unit!(value)
      id = wallet.currency_id
      x = value.to_d * Currency.find_by_code(id).base_factor
      unless (x % 1).zero?
        raise WalletClient::Error, "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: " +
            "#{value.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i
    end
  end
end
