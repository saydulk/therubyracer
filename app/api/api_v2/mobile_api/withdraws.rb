module APIv2
  module MobileApi
    class Withdraws < Grape::API

      helpers APIv2::MobileApi::Helpers
      before { authenticate! }

      desc 'To withdraws from one account to another'
      params do
        requires :currency, type: String, desc: 'for which type of currency is being used'
        requires :sum, type: Float, desc: 'Amount to be transferred.'
        requires :address, type: String, desc: 'A Hash key, For which transaction has to be created'
        optional :payment_id, type: String,  desc: 'Payment ID only for monero.'
      end
      post '/withdraws' do
        params.delete('payment_id') unless params['currency'] == 'xmr'
        withdraw_object = get_withdraw(params)
        if withdraw_object.valid?
          withdraw_object.save
          withdraw_object.submit!
          present withdraw_object, with: APIv2::Entities::Withdraw
        else
          present errors: withdraw_object.errors.full_messages.join(', '), success: false
        end
      end


      desc 'Get your withdraws history.'
      params do
        optional :currency, type: String, values: Currency.all.map(&:code), desc: "Currency value contains  #{Currency.all.map(&:code).join(',')}"
        optional :limit, type: Integer, range: 1..100, default: 30, desc: "Set result limit."
        optional :state, type: String, values: Withdraw::STATES.map(&:to_s)
      end
      get "/withdraws" do
        withdraws = current_user.withdraws.limit(params[:limit]).recent
        withdraws = withdraws.with_currency(params[:currency]) if params[:currency]
        withdraws = withdraws.with_aasm_state(params[:state]) if params[:state].present?

        present withdraws, with: APIv2::Entities::Withdraw
      end

      desc 'Get details of specific withdraw.'
      params do
        requires :txid
      end
      get "/withdraw" do
        withdraw = current_user.withdraws.find_by_txid(params[:txid])
        raise WithdrawByTxidNotFoundError, params[:txid] unless withdraw
        present withdraw, with: APIv2::Entities::Withdraw
      end
    end
  end
end