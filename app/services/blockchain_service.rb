# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  Error                  = Class.new(StandardError) # TODO: Rename to Exception.
  ConnectionRefusedError = Class.new(StandardError) # TODO: Remove this.

  class << self
    #
    # Returns Service for given blockchain key.
    #
    # @param key [String, Symbol]
    #   The blockchain key.
    def [](key)
      blockchain = Blockchain.find_by_key(key)
      if blockchain.try(:client).present?
        "BlockchainService::#{blockchain.client.capitalize}"
      end.constantize.new(blockchain)
    end
  end

  class Base

    attr_reader :blockchain, :client

    def initialize(blockchain)
      @blockchain = blockchain
      @client     = CoinAPI[blockchain.key]
    end

    protected

    def save_block(block, latest_block_number)
      block[:deposits].map { |d| d[:txid] }.join(',').tap do |txids|
        Rails.logger.info { "Deposit trancations in block #{block[:id]}: #{txids}" }
      end

      block[:withdrawals].map { |d| d[:txid] }.join(',').tap do |txids|
        Rails.logger.info { "Withdraw trancations in block #{block[:id]}: #{txids}" }
      end

      ActiveRecord::Base.transaction do
        update_or_create_deposits!(block[:deposits])
        update_withdrawals!(block[:withdrawals])
        update_height(block[:id], latest_block_number)
      end
    end


    def update_height(block_id, latest_block)
      raise Error, "#{blockchain.name} height was reset." if blockchain.height != blockchain.reload.height
      blockchain.update(height: block_id) if latest_block - block_id >= blockchain.min_confirmations
    end

    def currencies
      Currency.find_all_by_blockchain_key(blockchain.key)
    end

    def payment_addresses_where(options = {})
      options = { currency: currencies }.merge(options)
      PaymentAddress.where(options).each do |payment_address|
        yield payment_address if block_given?
      end
    end

    def wallets_where(options = {})
      options = { currency: currencies,
                  kind: %i[cold warm hot] }.merge(options)
      Wallet
        .includes(:currency)
        .where(options)
        .each do |wallet|
          yield wallet if block_given?
        end
    end

    def deposit_entry_processable?(channel, tx, entry, index)
      txid = tx["hash"] ? tx["hash"] : (tx["txid"] || tx["txID"])
      address = entry[:address] ? entry[:address] : channel.currency
      (PaymentAddress.where(currency: channel.currency, address: address).exists? &&
          !PaymentTransaction::Normal.where(txid: txid, txout: index).exists?)
    end
  end
end
