class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.string :name
      t.boolean :date_validity_choice, default: false
      t.boolean :no_of_referral_choice, default: false
      t.date :date_validity
      t.integer :no_of_referral
      t.integer :amount
      t.string :currency
      t.decimal :transaction_bonus
      t.integer :level_no
      t.boolean :status, default: false

      t.timestamps null: false
    end
  end
end
