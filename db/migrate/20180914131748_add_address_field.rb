class AddAddressField < ActiveRecord::Migration
  def change
    add_column :deposits, :address, :string unless column_exists?(:deposits, :address)
  end
end
