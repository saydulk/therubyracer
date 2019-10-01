class AddFieldsToLastChange < ActiveRecord::Migration
  def change
    add_column :members, :last_change, :datetime
  end
end
