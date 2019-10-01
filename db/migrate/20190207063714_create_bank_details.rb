class CreateBankDetails < ActiveRecord::Migration
  def change
    create_table :bank_details do |t|
      t.string :name
      t.string :bank_name
      t.string :account_number
      t.string :ifsc_code
      t.string :aasm_state
      t.boolean :active, default: false
      t.references :member, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
