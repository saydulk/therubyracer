class AddIsFakeToMember < ActiveRecord::Migration
  def up
    add_column :members, :is_fake, :boolean, default: false
  end

  def down
    remove_column :members, :is_fake
  end
end
