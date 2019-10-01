module Admin
  class CommissionsController < BaseController

    before_action :verify_auth, only: :create

    def index

    end

    def create
      @commission = Commission.new(commission_params)
      @error = false
      @commission.valid? ? @commission.save : (@error = true)

      respond_to do |format|
        format.html {}
        format.js
      end
    end

    private

    def verify_auth
      # return unless current_user.authenticate_otp(params[:otp_code], drift: 60)
    end

    def commission_params
      params.permit(:currency, :amount, :wallet_address, :receipent_address)
    end

  end
end
