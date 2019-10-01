class AddIsLockedIntoOrders < ActiveRecord::Migration
  def up
    add_column :orders, :is_locked, :boolean, default: false
  end

  def down
    remove_column :orders, :is_locked
  end
end
