class AddUnitBtcToMarketPrice < ActiveRecord::Migration
  def change
    add_column :market_prices, :btc_unit, :float
  end
end
