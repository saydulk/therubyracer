
module Private

  class ReferralController <  BaseController

    def invite
      @active_plan = Referral.active
    end

  end

end