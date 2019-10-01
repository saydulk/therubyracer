module Deposits
  class Fiat < ::Deposit
    include ::AasmAbsolutely
    include ::Deposits::Bankable
    # include ::FundSourceable
    validates :fund_uid, presence: true, on: :create
    validates :fund_extra, presence: false, on: :create

    # has_one :avatar, class_name: 'Asset::FiatDepositFile', as: :attachable
    # accepts_nested_attributes_for :avatar


    def charge!(txid)
      with_lock do
        submit!
        accept!
        touch(:done_at)
        update_attribute(:txid, txid)
      end
    end

  end
end
