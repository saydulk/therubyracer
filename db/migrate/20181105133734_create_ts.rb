class CreateTs < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.string   "currency_id",         limit: 255
      t.string   "wallet_address",      limit: 255
      t.string   "cold_wallet_address", limit: 255
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
      t.decimal  "amount", precision: 32, scale: 16
      t.string   "aasm_state",  limit: 255
      t.string   "txid", limit: 255

      t.timestamps null: false
    end
  end
end
