module Statistic
  class WithdrawsGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do
      Withdraw.includes(:account).order(id: :asc)
    end

    # filter(:channel, :enum, :select => WithdrawChannel.all, :default => 1, :include_blank => false)
    filter(:aasm_state, :enum, :select => Withdraw::STATES, :default => 2, include_blank: false)
    filter(:created_at, :datetime, :range => true, :default => proc { [30.day.ago, Time.now]})

    column(:member) do |model|
      format(model) do
        link_to model.account.member.name, member_path(model.member_id)
      end
    end

    column :currency do
      self.account.currency_text
    end

    column(:channel) do
      self.channel.type
    end


    column(:amount)
    column(:address) do
      self.fund_uid.mask
    end
    column_localtime :created_at
    column(:aasm_state_text)
  end
end
