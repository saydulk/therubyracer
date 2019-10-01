module Worker
  class DepositCollection
    def process(payload)
      Rails.logger.info {"Received request for deposit collection id: #{payload['id']}."}
      deposit = Deposit.find_by_id(payload['id'])

      unless deposit
        Rails.logger.warn {"The deposit with id: #{payload['id']} doesn't exist."}
        return
      end

      deposit.with_lock do
        begin
          if deposit.collected?
            Rails.logger.warn {"The deposit is now being processed by different worker or has been already processed. Skipping..."}
            return
          end
          currency_code = deposit.currency
          currency = Currency.find_by_code(currency_code).blockchain_key
          wallet = Wallet.active.deposit.find_by_currency_id(currency)
          unless wallet
            Rails.logger.warn {"Can't find active deposit wallet for currency with code: #{deposit.currency}."}
            return
          end
          # To stop recursive deposits
          Rails.logger.warn {"deposit "}
          return if deposit.address == wallet.address

          txid = WalletService[wallet].collect_deposit!(deposit)

          Rails.logger.warn {"The API accepted deposit collection and assigned transaction ID: #{txid}."}
          deposit.dispatch!
        rescue => e
          report_exception(e)
          raise e
        end
      end
    end
  end
end
