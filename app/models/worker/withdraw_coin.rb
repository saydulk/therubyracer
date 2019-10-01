# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class WithdrawCoin
    def process(payload)
      payload.symbolize_keys!

      Rails.logger.warn { ">>>>> Received request for processing withdraw ##{payload[:id]}." }

      withdraw = Withdraw.find_by_id(payload[:id])
      unless withdraw
        Rails.logger.warn {"The withdraw with such ID doesn't exist in database."}
        return
      end

      withdraw.with_lock do
        begin
          unless withdraw.processing?
            Rails.logger.warn {"The withdraw is now being processed by different worker or has been already processed. Skipping..."}
            return
          end

          if withdraw.fund_uid.blank?
            Rails.logger.warn {"The destination address doesn't exist. Skipping..."}
            withdraw.fail!
            return
          end

          Rails.logger.warn {"Information: sending #{withdraw.amount.to_s("F")} (exchange fee is #{withdraw.fee.to_s("F")}) #{withdraw.currency.upcase} to #{withdraw.fund_uid}."}
          currency_code = withdraw.currency
          currency_model = Currency.find_by_code(currency_code)

          #  Move only Eth and tokens into central wallet.
          if currency_model.is_erc20? or currency_model.code.eth?
            wallet = Wallet.active.withdraw.find_by(currency_id: currency_model.blockchain_key, kind: :hot)
            unless wallet
              Rails.logger.warn {"Can't find active hot wallet for currency with code: #{withdraw.currency}."}
              return
            end

            wallet_service = WalletService[wallet]

            balance = wallet_service.load_balance(wallet.address, currency_code)
            if balance < withdraw.sum
              Rails.logger.warn { "The withdraw failed because wallet balance is not sufficient (wallet balance is #{balance.to_s("F")})." }
              withdraw.fail!
              return
            end

            Rails.logger.warn {"Sending request to Wallet Service."}

            txid = wallet_service.build_withdrawal!(withdraw)
          else
            api     = currency_model.api
            balance = api.load_balance!

            if balance < withdraw.sum
              Rails.logger.warn { "The withdraw failed because wallet balance is not sufficient (wallet balance is #{balance.to_s("F")})." }
              withdraw.suspect!
              return
            end

            pa = withdraw.account.payment_address

            Rails.logger.warn { "Sending request to currency API." }

            txid = api.create_withdrawal!(
              { address: pa.address, secret: pa.secret },
              { address: withdraw.fund_uid },
              withdraw.amount.to_d
            )
          end

          Rails.logger.warn {"The currency API accepted withdraw and assigned transaction ID: #{txid}."}

          Rails.logger.warn {"Updating withdraw state in database."}

          withdraw.txid = txid
          withdraw.dispatch
          withdraw.succeed
          withdraw.save!

          Rails.logger.warn {"OK."}

        rescue Exception => e
          begin
            Rails.logger.error {"Failed to process withdraw. See exception details below."}
            report_exception(e)
            Rails.logger.warn {"Setting withdraw state to failed."}
          ensure
            withdraw.fail!
            Rails.logger.warn {"OK."}
          end
        end
      end
    end
  end
end
