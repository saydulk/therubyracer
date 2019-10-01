class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.string :modifiable_type
      t.integer :currency
      t.float :amount
      t.string :fund_uid
      t.string :txid
      t.timestamps null: false
    end
  end
end
