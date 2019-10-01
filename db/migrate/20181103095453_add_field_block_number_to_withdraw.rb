class AddFieldBlockNumberToWithdraw < ActiveRecord::Migration
  def change
    add_column :withdraws, :block_number, :integer, limit: 4
  end
end
