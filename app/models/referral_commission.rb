class ReferralCommission < ActiveRecord::Base
  belongs_to :member
  belongs_to :referral
end
