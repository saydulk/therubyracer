class CreateOrderExchanges < ActiveRecord::Migration
  def up
    create_table :order_exchanges do |t|
      t.integer :order_id
      t.string :uuid
      t.string :visited_exchange, array: true, default: []
      t.string :last_visit


      t.timestamps null: false
    end
  end

  def down
    drop_table :order_exchanges
  end
end
