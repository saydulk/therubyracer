module Private
  class FundsController < BaseController
    layout 'funds'

    # before_action :auth_activated!
    # before_action :auth_verified!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = Currency.all.sort
      # @currencies = Currency.all.sort_by &:priority
      @deposits = current_user.deposits.includes(:payment_transaction).order('created_at desc').limit(1000)
      @accounts = current_user.accounts.enabled
      @withdraws = current_user.withdraws.order('created_at desc').limit(1000)
      @fund_sources = current_user.fund_sources
      @markets = Market.all

      commission_fees = AccountVersion.where(" modifiable_type IN (?)", %w(Trade Withdraw))
      @commission_fees = commission_fees.select('modifiable_type, currency, sum(fee) as total_fees').group('modifiable_type, currency')
      @commission_list = Commission.select('currency, sum(amount) as total_commission , modifiable_type as modifiable_type').group('currency,modifiable_type').where(modifiable_type: ['Withdraw', 'Trade'])
      @banks = Bank.all
      @id_document = current_user.id_document

      gon.jbuilder
    end

    def gen_address
      current_user.accounts.each do |account|
        # next if not account.currency_obj.coin?
        next unless account.currency_obj.coin?

        if account.payment_addresses.blank?
          account.payment_addresses.create!(currency: account.currency)
        else
          address = account.payment_addresses.last
          address.gen_address if address.address.blank?
        end
      end
      render nothing: true
    end

  end
end

