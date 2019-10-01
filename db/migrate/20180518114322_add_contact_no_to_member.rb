class AddContactNoToMember < ActiveRecord::Migration
  def up
    add_column :members, :contact_no, :string, length: 15
  end

  def down
    remove_column :members, :contact_no
  end
end
