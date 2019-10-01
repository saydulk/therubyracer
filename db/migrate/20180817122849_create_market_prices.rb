class CreateMarketPrices < ActiveRecord::Migration
  def change
    create_table :market_prices do |t|
      t.string :amount, null: false, limit: 15
      t.string :base_unit, limit: 10, null:false

      t.timestamps null: false
    end
  end
end
