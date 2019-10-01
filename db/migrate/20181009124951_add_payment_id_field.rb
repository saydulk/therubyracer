class AddPaymentIdField < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :payment_id, :string
  end
end
