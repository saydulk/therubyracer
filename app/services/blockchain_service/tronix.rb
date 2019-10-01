module BlockchainService
  class Tronix < Base
    # Rough number of blocks per hour for Tronix is 10.
    def process_blockchain(blocks_limit: 20, force: false)
      latest_block = client.latest_block_number

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_block && !force
        Rails.logger.info {"Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_block: #{latest_block}"}
        return
      end
      from_block = blockchain.height || 0
      to_block     = [latest_block, from_block + blocks_limit].min
      (from_block..to_block).each do |block_id|
        block_json = client.get_block(block_id)
        next if block_json.blank? || block_json['transactions'].blank?
        deposits = build_deposits(block_json)
        withdrawals = build_withdrawals(block_json)
        deposits.map {|d| d[:txid]}.join(',').tap do |txids|
          Rails.logger.info {"Deposit trancations in block #{block_id}: #{txids}"}
        end

        withdrawals.map {|w| w[:txid]}.join(',').tap do |txids|
          Rails.logger.info {"Withdraw trancations in block #{block_id}: #{txids}"}
        end

        update_or_create_deposits!(deposits)
        update_withdrawals!(withdrawals)
        update_height(block_id, latest_block)

        Rails.logger.info {"Finished processing #{blockchain.key} block number #{block_id}."}
      end
    rescue => e
      report_exception(e)
      Rails.logger.info {"Exception was raised during block processing."}

    end

    private

    def build_deposits(block_json)
      block_json
          .fetch('transactions')
          .each_with_object([]) do |block_txn, deposits|
        payment_addresses_where(address: client.to_address(block_txn)) do |payment_address|
          deposit_txs = client.build_transaction(block_txn, block_json, payment_address.address)
          deposit_txs.fetch(:entries).each_with_index do |entry, i|
            unless deposit_entry_processable?(payment_address, block_txn, entry, i)
              Rails.logger.info " Skipped #{block_txn.inspect}:#{i}."
              deposits
              next
            end
            pt = PaymentTransaction::Normal.find_by_txid(deposit_txs[:id])
            pt = PaymentTransaction::Normal.create! \
                txid: deposit_txs[:id],
                txout: i,
                address: entry[:address],
                amount: entry[:amount],
                currency: payment_address.currency unless pt
            deposits << {txid: deposit_txs[:id],
                         payment_transaction_id: pt.id,
                         address: entry[:address],
                         amount: entry[:amount],
                         member: payment_address.account.member,
                         account: payment_address.account,
                         currency: payment_address.currency,
                         account_id: payment_address.account_id,
                         txout: i,
                         block_number: deposit_txs[:block_number]}
          end
        end
      end
    end

    def build_withdrawals(block_json)
      block_json
          .fetch('transactions')
          .each_with_object([]) do |block_txn, withdrawals|

        Withdraws::Tronix
          .where(currency: currencies)
          .where(txid:  client.normalize_txid(block_txn.fetch('txID')))
            .each do |withdraw|
          # If wallet currency doesn't match with blockchain transaction

          withdraw_txs = client.build_transaction(block_txn, block_json, withdraw.currency) # block_txn required for TRX transaction
          withdraw_txs.fetch(:entries).each do |entry|
            withdrawals << {txid: withdraw_txs[:id],
                            fund_uid: entry[:address],
                            amount: entry[:amount],
                            block_number: withdraw_txs[:block_number]}
          end
        end
      end
    end

    def
      update_or_create_deposits!(deposits)
      puts"============deposits==#{deposits.inspect}========="
      deposits.each do |deposit_hash|
        puts "===========deposit_hash====#{deposit_hash.inspect}============="

        # If deposit doesn't exist create it.
        id = deposit_hash.slice(:payment_transaction_id)
        deposit_currency= PaymentTransaction.find(id[:payment_transaction_id]).currency
        currency= Currency.find_by_code(deposit_currency)
        deposit = "Deposits::#{currency.key.capitalize}".camelize.constantize
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
      puts "==========withdrawals===eth============="
      withdrawals.each do |withdrawal_hash|
        puts"============withdrawal_hash===#{withdrawal_hash.inspect}===="
        withdrawal = Withdraws::Tronix
                         .confirming
                         .where(currency: currencies)
                         .find_by(withdrawal_hash.except(:block_number))

        # Skip non-existing in database withdrawals.
        if withdrawal.blank?
          Rails.logger.info {"Skipped withdrawal: #{withdrawal_hash[:txid]}."}
          next
        end

        withdrawal.update_column(block_number: withdrawal_hash.fetch(:block_number))
        withdrawal.success! #if withdrawal.confirmations >= blockchain.min_confirmations
      end
    end
  end
end