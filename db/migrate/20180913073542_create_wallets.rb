class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.string   :blockchain_key, limit: 32
      t.string   :currency_id,    limit: 10
      t.string   :name,           limit: 64
      t.string   :address,        limit: 255,                                           null: false
      t.string   :kind,           limit: 32,                                            null: false
      t.integer  :nsig,           limit: 4
      t.string   :gateway,        limit: 20,                             default: "",   null: false
      t.string   :settings,       limit: 1000,                           default: "{}", null: false
      t.decimal  :max_balance,                 precision: 32, scale: 16, default: 0.0,  null: false
      t.integer  :parent,         limit: 4
      t.string   :status,         limit: 32

      t.timestamps null: false

    end
  end
end
