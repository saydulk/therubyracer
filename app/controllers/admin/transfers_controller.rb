module Admin
  class TransfersController < BaseController


    def transfer_amount
      @currency = Currency.all
      @transfer = Transfer.all
    end

    def withdrawl_amount
      currency_id = params[:currency_id]
      issuer_address = params[:issuer_address]
      receipent_address = params[:receipent_address]
      amount = params[:amount]
      transfer = Transfer.create(currency_id: currency_id, wallet_address: issuer_address, cold_wallet_address: receipent_address, amount: amount)
      @transfer = Transfer.all
      #transfer.audit_transfer!
      puts"=============transfer===========process==========#{transfer.inspect}"
      if request.xhr?
        respond_to do |format|
          format.js
        end
      end
    end

    def verify_auth
      render json: current_user.authenticate_otp(params[:google_code], drift: 60)
    end

  end
end
