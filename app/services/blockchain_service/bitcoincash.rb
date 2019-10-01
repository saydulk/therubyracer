# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Bitcoincash < Base

    # Rough number of blocks per hour for Bitcoin is 6.
    def process_blockchain(blocks_limit: 20, force: false)
      latest_block = client.latest_block_number

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_block && !force
        Rails.logger.info { "Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_block: #{latest_block}" }
        fetch_unconfirmed_deposits
        return
      end

      from_block   = blockchain.height || 0
      to_block     = [latest_block, from_block + blocks_limit].min

      (from_block..to_block).each do |block_id|
        Rails.logger.info { "Started processing #{blockchain.key} block number #{block_id}." }

        block_hash = client.get_block_hash(block_id)
        next if block_hash.blank?

        block_json = client.get_block(block_hash)
        next if block_json.blank? || block_json['tx'].blank?

        block_data = { id: block_id }
        block_data[:deposits]    = build_deposits(block_json, block_id)
        block_data[:withdrawals] = build_withdrawals(block_json, block_id)

        save_block(block_data, latest_block)

        Rails.logger.info { "Finished processing #{blockchain.key} block number #{block_id}." }
      end
    rescue => e
      report_exception(e)
      Rails.logger.info { "Exception was raised during block processing." }
    end

    private

    def build_deposits(block_json, block_id)
      block_json
          .fetch('tx')
          .each_with_object([]) do |tx, deposits|
         tx = tx["txid"]
        # get raw transaction
        txn = client.get_raw_transaction(tx)

        payment_addresses_where(address: client.to_address(txn)) do |payment_address|
          # If payment address currency doesn't match with blockchain

          deposit_txs = client.build_transaction(txn, block_id, payment_address.address)

          deposit_txs.fetch(:entries).each_with_index do |entry, i|
            if entry[:amount] <= Currency.find_by_code(payment_address.currency).min_deposit_amount
              # Currently we just skip small deposits. Custom behavior will be implemented later.
              Rails.logger.info do  "Skipped deposit with txid: #{deposit_txs[:id]} with amount: #{entry[:amount]}"\
                                     " from #{entry[:address]} in block number #{deposit_txs[:block_number]}"
              end
              next
            end
            unless deposit_entry_processable?(payment_address,txn, entry, i)
              Rails.logger.info " Skipped #{txn.fetch("txid")}:#{i}."
              deposits
              next
            end
            deposit_legacy_address = client.coin_legacy_address(entry[:address])
            pt = PaymentTransaction::Normal.create! \
                txid: deposit_txs[:id],
                txout: i,
                address: entry[:address],
                amount: entry[:amount],
                currency: payment_address.currency
            deposits << { txid:           deposit_txs[:id],
                          payment_transaction_id: pt.id,
                          address:        deposit_legacy_address,
                          amount:         entry[:amount],
                          member:         payment_address.account.member,
                          account:        payment_address.account,
                          currency:       payment_address.currency,
                          txout:          i,
                          block_number:   deposit_txs[:block_number] }
          end
        end
      end
    end

    def build_withdrawals(block_json, block_id)
      block_json
          .fetch('tx')
          .each_with_object([]) do |tx, withdrawals|
        tx = tx["txid"]
        Withdraws::BitcoinCash
          .where(currency: currencies)
          .where(txid: client.normalize_txid(tx))
          .each do |withdraw|
          # If wallet currency doesn't match with blockchain transaction

          # get raw transaction
          txn = client.get_raw_transaction(tx)

          withdraw_txs = client.build_transaction(txn, block_id, withdraw.fund_uid)
          withdraw_txs.fetch(:entries).each do |entry|
            withdrawals << {  txid:           withdraw_txs[:id],
                              fund_uid:            entry[:address],
                              amount:         entry[:amount],
                              block_number:   withdraw_txs[:block_number] }
          end
        end
      end
    end
    def fetch_unconfirmed_deposits(block_json = {})
      Rails.logger.info { "Processing unconfirmed deposits." }
      txns = client.get_unconfirmed_txns

      # Read processed mempool tx ids because we can skip them.
      processed = Rails.cache.read("processed_#{self.class.name.underscore}_mempool_txids") || []

      # Skip processed txs.
      block_json.merge!('tx' => txns - processed)
      deposits = build_deposits(block_json, nil)
      update_or_create_deposits!(deposits)

      # Store processed tx ids from mempool.
      Rails.cache.write("processed_#{self.class.name.underscore}_mempool_txids", txns)
    end


    def update_or_create_deposits!(deposits)
      deposits.each do |deposit_hash|

        # If deposit doesn't exist create it.
        deposit = Deposits::BitcoinCash
                      .where(currency: currencies)
                      .find_or_create_by!(deposit_hash.slice(:txid)) do |deposit|
          deposit.assign_attributes(deposit_hash)
        end

        deposit.update_column(:block_number, deposit_hash.fetch(:block_number))
        #if deposit.confirmations.to_i >= blockchain.min_confirmations
          deposit.accept!
          # deposit.collect!
        #end
      end
    end

    def update_withdrawals!(withdrawals)
      withdrawals.each do |withdrawal_hash|

        withdrawal = Withdraws::BitcoinCash
                         .confirming
                         .where(currency: currencies)
                         .find_by(withdrawal_hash.except(:block_number))

        # Skip non-existing in database withdrawals.
        if withdrawal.blank?
          Rails.logger.info { "Skipped withdrawal: #{withdrawal_hash[:txid]}." }
          next
        end

        withdrawal.update(block_number: withdrawal_hash.fetch(:block_number)) if withdrawal.block_number.blank?
        withdrawal.success! #if withdrawal.confirmations >= blockchain.min_confirmations
      end
    end
  end
end

