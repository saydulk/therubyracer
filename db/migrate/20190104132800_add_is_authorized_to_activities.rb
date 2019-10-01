class AddIsAuthorizedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_authorized, :boolean , :default => false
  end
end
