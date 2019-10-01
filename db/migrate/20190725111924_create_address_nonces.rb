class CreateAddressNonces < ActiveRecord::Migration
  def change
    create_table :address_nonces do |t|
      t.string :address
      t.integer :nonce

      t.timestamps null: false
    end
  end
end
