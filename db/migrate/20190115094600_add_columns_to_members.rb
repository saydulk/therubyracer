class AddColumnsToMembers < ActiveRecord::Migration
  def up
    add_column :members, :referral_id, :integer
    add_column :members, :sponsor_id, :integer
  end

  def down
    remove_columns :members, :referral_id, :sponsor_id
  end
end
