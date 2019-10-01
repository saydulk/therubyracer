class AddColumnsToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :wallet_address, :string, null: false
    add_column :commissions, :aasm_state, :string
    rename_column :commissions, :fund_uid, :receipent_address
  end
end
