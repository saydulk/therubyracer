json.current_user @current_user
json.deposit_channels @deposit_channels
json.withdraw_channels @withdraw_channels
json.currencies @currencies
json.deposits @deposits
json.accounts @accounts
json.withdraws @withdraws
json.fund_sources @fund_sources
json.markets @markets
json.account_versions @commission_fees
json.commissions @commission_list
json.banks @banks.map(&:attributes), :currency, :code
