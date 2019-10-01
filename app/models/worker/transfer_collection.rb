# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class TransferCollection
    puts "=====TransferCollection=====worker========================"

    def process(payload)
      payload.symbolize_keys!

      Rails.logger.warn {">>>>> Received request for processing transfer ##{payload[:transfer_id]}."}

      transfer = Transfer.find_by_id(payload[:transfer_id])
      puts "======transfer=coin==#{transfer.inspect}================"

      unless transfer
        Rails.logger.warn {"The transfer with such ID doesn't exist in database."}
        return
      end

      transfer.with_lock do
        puts "======with_lock=do==transfer==#{transfer.inspect}====="
        begin
          unless transfer.processing?
            puts "====unless======================"
            Rails.logger.warn {"The transfer is now being processed by different worker or has been already processed. Skipping..."}
            return
          end

          if transfer.cold_wallet_address.blank?
            puts "=========transfer.cold_wallet_address.blank?============"
            Rails.logger.warn {"The destination address doesn't exist. Skipping..."}
            transfer.fail!
            return
          end
          currency_model = Currency.find_by_code(transfer.currency_id)
          #  Move only Eth , tokens and xrp  into cold wallet.
          if currency_model.is_erc20? or currency_model.code.eth? or currency_model.code.xrp?
            wallet = Wallet.active.withdraw.find_by(currency_id: currency_model.blockchain_key, kind: :hot)
            puts "==============wallet=========#{wallet.inspect}"
            unless wallet
              Rails.logger.warn {"Can't find active hot wallet for currency with code: #{transfer.currency_id}."}
              return
            end
            wallet_service = WalletService[wallet]
            puts "========wallet_service=====#{wallet_service.inspect}======================"
            balance = wallet_service.load_balance(wallet.address, currency_model.code)
            if balance < transfer.amount
              Rails.logger.warn {"The Transfer failed because wallet balance is not sufficient (wallet balance is #{balance.to_s("F")})."}
              transfer.suspect!
              return
            end
            Rails.logger.warn {"Sending request to Wallet Service."}
            # txid = wallet_service.transfer_withdrawal!(transfer)
            txid = wallet_service.build_withdrawal!(transfer)
            puts "============txid========#{txid.inspect}"
          else
            api = currency_model.api
            balance = api.load_balance!

            if balance < transfer.amount
              Rails.logger.warn {"The Transfer failed because wallet balance is not sufficient (wallet balance is #{balance.to_s("F")})."}
              transfer.suspect!
              return
            end
            Rails.logger.warn {"Sending request to currency API."}

            txid = api.create_withdrawal!(
                {},
                {address: transfer.cold_wallet_address},
                transfer.amount.to_d
            )
            puts "============txid========#{txid.inspect}"
          end
          Rails.logger.warn {"The currency API accepted transfer and assigned transaction ID: #{txid}."}

          Rails.logger.warn {"Updating transfer state in database."}

          transfer.txid = txid
          transfer.dispatch
          transfer.succeed
          transfer.save!

          Rails.logger.warn {"OK."}

        rescue Exception => e
          begin
            Rails.logger.error {"Failed to process transfer. See exception details below."}
            report_exception(e)
            Rails.logger.warn {"Setting withdraw state to failed."}
          ensure
            transfer.fail!
            Rails.logger.warn {"OK."}
          end
        end
      end
    end
  end
end
