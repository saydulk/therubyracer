module Statistic
  class CommissionsGrid
    include Datagrid
    include Datagrid::Naming
    include Datagrid::ColumnI18n

    scope do
      Commission.all
    end

    filter(:currency, :enum, :select => [["btc", 1], ["bch", 2]], :default => 1, include_blank: false)

    column :currency do
      self.currency.upcase
    end

    column(:amount)

    column(:receipent_address)

    column(:txid)

    column(:status) do
      self.aasm_state
    end
  end
end
