class CreateReferralCommissions < ActiveRecord::Migration
  def change
    create_table :referral_commissions do |t|
      t.float :transaction_bonus
      t.float :bonus_percentage
      t.integer :referral_amount
      t.string :currency
      t.integer :sponsor_id
      t.integer :referrent_id
      t.references :referral
      t.timestamps null: false
    end
  end
end
