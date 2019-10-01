class AddModifiableTypeToWithdraws < ActiveRecord::Migration
  def change
    add_column :withdraws, :modifiable_type, :string
  end
end
