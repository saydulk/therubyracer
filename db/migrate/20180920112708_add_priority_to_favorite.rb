class AddPriorityToFavorite < ActiveRecord::Migration
  def change
    add_column :favorites, :priority, :integer
  end
end
