module Withdraws::Commission
  class Satoshi < ::Withdraw
    include ::AasmAbsolutely
    include ::Withdraws::Coinable
    include ::FundSourceable

    private

    def lock_funds
      return  #'For commission. No action'
    end

    def unlock_funds
      return  #'For commission. No action'
    end

    def unlock_and_sub_funds
      return  #'For commission. No action'
    end

    def send_email
      return  #'For commission. No action'
    end

    def ensure_account_balance
      if sum.nil? or sum > 1
        errors.add :base, -> {I18n.t('activerecord.errors.models.withdraw.account_balance_is_poor')}
      end
    end

    def calc_fee
      self.sum ||= 0.0
      self.fee = 0.0
      self.amount = sum
    end
  end
end


