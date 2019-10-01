module Admin
  class ReferralsController < BaseController
    load_and_authorize_resource

    before_filter :find_plan, only: %w(edit update destroy active)

    def index
      @referral_plans = Referral.all
    end

    def new
      @referral = Referral.new
    end

    def create
      @referral = Referral.new(referral_params)
      if @referral.save
        redirect_to admin_referrals_path
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @referral.update_attributes(referral_params)
        redirect_to admin_referrals_path
      else
        render :edit
      end
    end

    def destroy
      @referral.delete
      redirect_to admin_referrals_path
    end

    def active
      if @referral
        Referral.update_all(status: false)
        @referral.update(status: true)
      end
      render nothing: true
    end

    private

    def referral_params
      params.require(:referral).permit(
          :name,
          :date_validity_choice,
          :no_of_referral_choice,
          :date_validity,
          :no_of_referral,
          :amount,
          :currency,
          :transaction_bonus,
          :level_no,
          :status
      )
    end

    def find_plan
      @referral = Referral.find_by(id: params[:id])
    end
  end
end
