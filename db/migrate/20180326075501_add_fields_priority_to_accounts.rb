class AddFieldsPriorityToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :priority, :integer
  end
end
