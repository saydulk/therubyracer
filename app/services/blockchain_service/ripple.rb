# encoding: UTF-8
# frozen_string_literal: true

module BlockchainService
  class Ripple < Base
    def process_blockchain(blocks_limit: 300, force: false)
      if blockchain.height > 0
        current_ledger   = blockchain.height
        latest_ledger    = [client.latest_block_number, current_ledger + blocks_limit].min
      else
        latest_ledger = client.latest_block_number
        current_ledger = latest_ledger
      end

      # Don't start process if we didn't receive new blocks.
      if blockchain.height + blockchain.min_confirmations >= latest_ledger && !force
        Rails.logger.info { "Skip synchronization. No new blocks detected height: #{blockchain.height}, latest_ledger: #{latest_ledger}" }
        return
      end

      (current_ledger..latest_ledger).each do |ledger_index|
        Rails.logger.info { "Started processing #{blockchain.key} ledger #{ledger_index}." }

        transactions = client.fetch_transactions(ledger_index)
        next if transactions.blank?

        block_data = { id: ledger_index }
        block_data[:deposits]    = build_deposits(transactions, ledger_index)
        block_data[:withdrawals] = build_withdrawals(transactions, ledger_index)

        save_block(block_data, latest_ledger)

        Rails.logger.info { "Finished processing #{blockchain.key} ledger #{ledger_index}." }
      end
    rescue => e
      report_exception(e)
      Rails.logger.info { "Exception was raised during block processing." }
    end

    private

    def build_deposits(transactions, ledger_index)
      transactions.each_with_object([]) do |tx, deposits|
        next unless valid_transaction?(tx)

        destination_tag = tx['DestinationTag'] || client.destination_tag_from(tx['Destination'])
        address = "#{client.to_address(tx)}?dt=#{destination_tag}"

        payment_addresses_where(address: address) do |payment_address|
          deposit_txs = client.build_transaction(tx: tx, currency: payment_address.currency)
          deposit_txs.fetch(:entries).each_with_index do |entry, index|
            if entry[:amount] <= Currency.find_by_code(payment_address.currency).min_deposit_amount
              # Currently we just skip small deposits. Custom behavior will be implemented later.
              Rails.logger.info do  "Skipped deposit with txid: #{deposit_txs[:id]} with amount: #{entry[:amount]}"\
                                     " from #{address} in block number #{ledger_index}"
              end
              next
            end
            unless deposit_entry_processable?(payment_address,tx, entry, index)
              Rails.logger.info " Skipped #{tx.fetch("hash")}:#{index}."
              deposits
              next
            end
            pt = PaymentTransaction::Normal.create! \
                txid: deposit_txs[:id],
                txout: index,
                address: entry[:address],
                amount: entry[:amount],
                currency: payment_address.currency
            deposits << {
                txid:           deposit_txs[:id],
                payment_transaction_id: pt.id,
                address:        address,
                amount:         entry[:amount],
                member:         payment_address.account.member,
                account:        payment_address.account,
                currency:       payment_address.currency,
                txout:          index,
                block_number:   ledger_index
            }

          end
        end
      end
    end

    def build_withdrawals(transactions, ledger_index)
      transactions.each_with_object([]) do |tx, withdrawals|
        next unless valid_transaction?(tx)

        Withdraws::Ripple
            .where(currency: currencies)
            .where(txid: client.normalize_txid(tx.fetch('hash')))
            .each do |withdraw|
          withdraw_txs = client.build_transaction(tx: tx,
                                                  currency: withdraw.currency)
          withdraw_txs.fetch(:entries).each do |entry|
            withdrawals << {
                txid:           withdraw_txs[:id],
                fund_uid:            client.to_address(tx),
                amount:         entry[:amount],
                block_number:   ledger_index
            }
          end
        end
      end
    end

    def valid_transaction?(tx)
      client.inspect_address!(tx['Account'])[:is_valid] &&
          tx['TransactionType'].to_s == 'Payment' &&
          tx.dig('metaData', 'TransactionResult').to_s == 'tesSUCCESS' &&
          String === tx['Amount']
    end

    def update_or_create_deposits!(deposits)
      deposits.each do |deposit_hash|

        # If deposit doesn't exist create it.
        deposit = Deposits::Ripple
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

        withdrawal = Withdraws::Ripple
                         .confirming
                         .where(currency: currencies)
                         .find_by(withdrawal_hash.except(:block_number))

        # Skip non-existing in database withdrawals.
        if withdrawal.blank?
          Rails.logger.info { "Skipped withdrawal: #{withdrawal_hash[:txid]}." }
          next
        end

        withdrawal.update_column(block_number: withdrawal_hash.fetch(:block_number))
        withdrawal.success! #if withdrawal.confirmations >= blockchain.min_confirmations
      end
    end
  end

end

