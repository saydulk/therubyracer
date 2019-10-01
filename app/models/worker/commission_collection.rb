# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class CommissionCollection
    def process(payload)
      payload.symbolize_keys!

      Rails.logger.warn { ">>>>> Received request for processing commission ##{payload[:commission_id]}." }

      commission = Commission.find_by_id(payload[:commission_id])

      unless commission
        Rails.logger.warn { "The commission with such ID doesn't exist in database." }
        return
      end

      commission.with_lock do
        begin
          unless commission.processing?
            Rails.logger.warn { "The commission is now being processed by different worker or has been already processed. Skipping..." }
            return
          end

          if commission.receipent_address.blank?
            Rails.logger.warn { "The destination address doesn't exist. Skipping..." }
            commission.fail!
            return
          end


          wallet = Wallet.active.withdraw.find_by(currency_id: commission.currency, kind: :hot)
          unless wallet
            Rails.logger.warn { "Can't find active hot wallet for currency with code: #{commission.currency}."}
            return
          end

          currency = commission.currency

          wallet_service = WalletService[wallet]


          Rails.logger.warn { "Sending request to Wallet Service." }

          txid = wallet_service.transfer_withdrawal!(commission)

          Rails.logger.warn { "The currency API accepted commission and assigned transaction ID: #{txid}." }

          Rails.logger.warn { "Updating commission state in database." }

          commission.txid = txid
          commission.dispatch
          commission.succeed
          commission.save!


          Rails.logger.warn { "OK." }

        rescue Exception => e
          begin
            Rails.logger.error { "Failed to process commission. See exception details below." }
            report_exception(e)
            Rails.logger.warn { "Setting withdraw state to failed." }
          ensure
            commission.fail!
            Rails.logger.warn { "OK." }
          end
        end
      end
    end
  end
end
