module Statistic
  class TradesGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do
      Trade.joins(:ask_member, :bid_member).where(' members.is_fake = ? ', false).order('created_at asc')
    end

    filter(:currency, :enum, :select => Trade.currency.value_options, :default => 1, include_blank: false)
    filter(:created_at, :datetime, :range => true, :default => proc { [30.day.ago, Time.now]})

    column(:id, :order => nil)
    column(:ask_id, :order => nil)
    column(:bid_id, :order => nil)
    column(:price)
    column(:volume)
    column(:strike_amount) { price * volume }
    column_localtime :created_at
  end
end
