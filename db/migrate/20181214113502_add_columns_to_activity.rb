class AddColumnsToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :browser_type, :string
    add_column :activities, :is_logged, :boolean, :default => false
    add_column :activities, :session_id, :string
  end
end
