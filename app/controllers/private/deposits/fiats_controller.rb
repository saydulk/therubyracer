module Private
  module Deposits
    class FiatsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlBankable

      def create
        deposit = ::Deposits::Fiat.new(params_fiat_deposit)
        if deposit.save
          FiatAttachment.create(deposit_id: deposit.id, avatar: params[:deposit][:avatar])
        end
        render json: true
      end

      private

      def params_fiat_deposit
        params.require(:deposit).permit(:amount, :done_at, :currency, :fund_uid,).tap do |whitelisted|
          whitelisted[:account_id] = current_user.accounts.find_by_currency(params[:deposit][:currency])&.id
          whitelisted[:member_id] = current_user.id
          whitelisted[:fund_extra] = params[:deposit][:currency]
        end
      end

    end
  end
end
