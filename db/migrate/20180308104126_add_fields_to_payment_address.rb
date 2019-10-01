class AddFieldsToPaymentAddress < ActiveRecord::Migration
  def change
    add_column :payment_addresses, :legacy_address, :string

  end
end
